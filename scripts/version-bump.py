#!/bin/env/python3
import os
import os.path
import subprocess
from shutil import rmtree
import re
from datetime import date

class File(object):

    def __init__(self, path, version_string):
        self.path = path
        self.name = os.path.basename(path)
        self.version_string = version_string

    def bump_version(self):
        try:
            with open(self.path, "r+") as file:
                new_content = []
                new_version_string = ""

                for line in file.readlines():
                    if self.version_string not in line:
                        new_content.append(line)
                    else:
                        parsed_out_numbers = [int(s) for s in re.findall(r'\b\d+\b', line)]
                        current_version_string = '.'.join(str(number) for number in parsed_out_numbers)

                        parsed_out_numbers[2] = parsed_out_numbers[2] + 1
                        new_version_string = '.'.join(str(number) for number in parsed_out_numbers)

                        new_line_to_save = line.replace(current_version_string, new_version_string)

                        print(f"bumping version from {current_version_string} to {new_version_string}")

                        new_content.append(new_line_to_save)

                new_content = "".join(new_content)
                file.truncate(0)
                file.seek(0)
                file.write(new_content)
                return new_version_string

        except:
            print(f"Warning: Unable to open or write to file {self.path}")

class VersionBumpHelper(object):

    def __init__(self):

        self.rk_shared_file = File('../ResearchKit/Configuration/ResearchKit/ResearchKit-Shared.xcconfig', 'ORK_FRAMEWORK_VERSION_NUMBER =')
        self.catalog_shared_file = File('../samples/ORKCatalog/ResearchKit-Shared.xcconfig', 'ORK_CATALOG_VERSION_NUMBER =')
        self.new_version_number = None # === this is set within the bump_version method ===

        # === check if all saved file paths exists ===
        self.__check_files()

    def bump_version(self):
        rk_shared_file_new_version = self.rk_shared_file.bump_version()
        catalog_shared_file_new_version = self.catalog_shared_file.bump_version()

        if rk_shared_file_new_version == catalog_shared_file_new_version:
            self.new_version_number = rk_shared_file_new_version
        else:
            raise Exception(f"ERROR: The version numbers from the shared files don't match. Please check before moving forward")

    def __check_files(self):

        if not os.path.exists(self.rk_shared_file.path):
            raise Exception(f"ERROR: {file.path} file not found. Please make sure you're running the version-bump.py script from within the script folder.")

        if not os.path.exists(self.catalog_shared_file.path):
            raise Exception(f"ERROR: {file.path} file not found. Please make sure you're running the version-bump.py script from within the script folder.")

class GitHelper(object):

    def __init__(self):
        self.current_branch = self.__check_current_branch()

    def add_and_commit(self, version_bump_helper):

        git_add_result = subprocess.run(["git", "add", version_bump_helper.rk_shared_file.path, version_bump_helper.catalog_shared_file.path], capture_output=True, text=True)

        if git_add_result.stderr != "" :
            raise Exception(f"ERROR: ran into issue while attempting to add your changes")

        commit_message = "Bumped Version to " + version_bump_helper.new_version_number
        git_commit_result = subprocess.run(["git", "commit", "-m", commit_message], capture_output=True, text=True)

        if git_commit_result.stderr != "" :
            raise Exception(f"ERROR: ran into issue while attempting to commit your changes")

        print(git_commit_result.stdout)

    def push_changes(self):
        print(f"Pushing your changes to origin: ({self.current_branch})")
        git_push_result = subprocess.run(["git", "push", "origin", self.current_branch], capture_output=True, text=True)

        if "To github.pie.apple" not in git_push_result.stderr != "" :
            print(git_push_result.stderr)
            raise Exception(f"ERROR: ran into issue while attempting to push your changes")

    def tag_changes(self, new_version_number):

        # === create tag locally ===
        print("Tagging your changes locally")
        tag_name = "ResearchKit-Release-" + new_version_number
        today = date.today()
        tag_message = "tagging new version (" + new_version_number + ") on " + today.strftime("%d/%m/%Y")
        git_tag_result = subprocess.run(["git", "tag", "-a", tag_name, "-m", tag_message], capture_output=True, text=True)

        if git_tag_result.stderr != "" :
            raise Exception(f"ERROR: ran into issue while attempting to tag your changes")

        # === pushing tag to remote repo ===
        print("Pushing tag to remote repo")
        git_push_tag_result = subprocess.run(["git", "push", "origin", tag_name], capture_output=True, text=True)

        if git_push_tag_result.stderr != "" :
            raise Exception(f"ERROR: ran into issue while attempting to push your tag")

        print(git_push_tag_result.stdout)

    def __check_current_branch(self):

        result = subprocess.run(["git", "branch", "--show-current"], capture_output=True, text=True)

        if result.stderr == "" :
            return result.stdout.rstrip()

        raise Exception(f"ERROR: Couldn't find current branch. Please make sure you're running the version-bump.py script from within the script folder.")

if __name__ == "__main__":

    git_helper = GitHelper()

    print(f"YOUR CURRENT BRANCH IS: ({git_helper.current_branch})")
    response = input('Is this the branch you wish to push to?\n (yes/no)')

    if response == "y" or response == "yes":

        version_bump_helper = VersionBumpHelper()
        version_bump_helper.bump_version()

        # === add and commit ===
        git_helper.add_and_commit(version_bump_helper)

        # === push changes to remote branch ===
        git_helper.push_changes()

        # === tag changes ===
        git_helper.tag_changes(version_bump_helper.new_version_number)

    else:
        print("Please change branch and run this script again.")
