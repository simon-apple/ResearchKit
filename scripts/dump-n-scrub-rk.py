#!/bin/env/python3
import os
from shutil import rmtree

class File(object):

    def __init__(self, path):
        self.path = path
        self.name = os.path.basename(path)

    def delete(self):
        os.remove(self.path)

    def contains_text(self, text):
        try:
            with open(self.path) as file:
                content = file.read()
                if text in content:
                    return True
                else:
                    return False
        except:
            print(f"Warning: Unable to open file {self.path}")
            return False

    def remove_lines_containing(self, text):
        try:
            with open(self.path, "r+") as file:
                new_content = []
                for line in file.readlines():
                    if text not in line:
                        new_content.append(line)
                new_content = "".join(new_content)
                file.truncate(0)
                file.seek(0)
                file.write(new_content)
        except:
            print(f"Warning: Unable to open or write to file {self.path}")

    def remove_internal_code(self, start_delimeter, end_delimeter):
        try:
            with open(self.path, "r+") as file:
                should_skip = False
                new_content = []
                for line in file.readlines():

                    if start_delimeter in line:
                        should_skip = True

                    if not should_skip:
                        new_content.append(line)

                    if end_delimeter in line:
                        should_skip = False

                new_content = "".join(new_content)
                file.truncate(0)
                file.seek(0)
                file.write(new_content)

        except:
            print(f"Warning: Unable to open or write to file {self.path}")

        if should_skip:
            raise Exception(f"Encountered unpaired delimeter {start_delimeter} in file {self.name}")



def recursively_read_files():
    all_files = []
    for root, _, files in os.walk("."):
        if ".git" not in root:
            for name in files:
                if name != os.path.basename(__file__) \
                    and ".png" not in name \
                    and ".jpg" not in name:

                    path = os.path.join(root, name)
                    all_files.append(File(path))
    return all_files

# recursive function that parses all RK folders and deletes all internal folders and their content
def delete_internal_folders():
    for root, folders, _ in os.walk("../ResearchKit"):
        for folder in folders:
                if is_a_folder_to_delete(folder):
                    path = os.path.join(root, folder)
                    print(f"Deleting folder and its contents at path: {path}")
                    rmtree(path)

# helper function to that determines if a specific folder should be deleted along with its contents
def is_a_folder_to_delete(current_folder):
    # hardcoded list of folders that need to be removed before pushing to public
    folders_to_delete = ["PrivateHeaders", "ORKAVJournaling", "ORKFaceDetectionStep"]
    for folder in folders_to_delete:
        if folder == current_folder:
            return True

    return False

if __name__ == "__main__":

    # delete all internal folders
    delete_internal_folders()
