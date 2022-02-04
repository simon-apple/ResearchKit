#!/bin/env/python3
import os
from shutil import rmtree

class File(object):

    def __init__(self, path):
        self.path = path
        self.name = os.path.basename(path)

    def delete(self):
        if os.path.exists(self.path):
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
    for root, _, files in os.walk("../ResearchKit"):
        if ".git" not in root:
            for name in files:
                if name != os.path.basename(__file__) \
                    and ".png" not in name \
                    and ".jpg" not in name:

                    path = os.path.join(root, name)
                    all_files.append(File(path))
    return all_files

def fetch_folders_to_delete():
    folders_to_delete = []
    for root, folders, _ in os.walk("../ResearchKit"):
        for folder in folders:
                if is_a_folder_to_delete(folder):
                    path = os.path.join(root, folder)
                    folders_to_delete.append(path)

    return folders_to_delete

def gather_files_from_internal_folders(folders):
    internal_files = []

    for folder in folders:
        internal_files = internal_files + fetch_files_from_folder(folder)



    return internal_files

def is_a_folder_to_delete(current_folder):
    # hardcoded list of folders that need to be removed before pushing to public
    folders_to_remove = ["PrivateHeaders", "ORKAVJournaling", "ORKFaceDetectionStep", "Tinnitus", "ORKVolumeCalibration", "HeadphoneDetectStep", "InternalPredefinedTasks"]
    for folder in folders_to_remove:
        if folder == current_folder:
            return True

    return False

def fetch_files_from_folder(folder_path):
    filelist = []

    for root, dirs, files in os.walk(folder_path):

    	for file in files:
            #append the file name to the list
    		filelist.append(File(os.path.join(root,file)))

    return filelist

if __name__ == "__main__":

    # paths to internal folders that need to be deleted
    folders_to_delete = fetch_folders_to_delete()

    # files from within internal folders
    files_to_delete = gather_files_from_internal_folders(folders_to_delete)

    special_comment = "apple-internal"

    # gather all files from project
    files = recursively_read_files()

    # filter out files with special 'apple-internal' comment
    files_with_special_comment = [f for f in files if f.contains_text(special_comment)]

    # combine fiels with special comment with files fetched from internal folders
    files_to_delete = files_to_delete + files_with_special_comment

    for file in files_to_delete:
        print(f"File to be scrubbed: {file.path}")

    pbx_file = File("../ResearchKit.xcodeproj/project.pbxproj")
    for f in files_to_delete:
        pbx_file.remove_lines_containing(f.name)

    print(f"Finished removing references in ResearchKit project file")

    for f in files:
        start_comment = "start-omit-internal-code"
        end_comment = "end-omit-internal-code"
        f.remove_internal_code(start_delimeter=start_comment, end_delimeter=end_comment)
        f.remove_lines_containing("swiftlint")
        f.remove_lines_containing("// TODO:")
        f.remove_lines_containing("// FIXME:")
        f.remove_lines_containing("rdar://")
    print("Done!")

    for f in files_to_delete:
        f.delete()
        print(f"\tDeleted file {f.name}")

    for folder in folders_to_delete:
        if os.path.exists(folder):
            rmtree(folder)
            print(f"\tDeleted filder {folder}")

    print("Success!")
