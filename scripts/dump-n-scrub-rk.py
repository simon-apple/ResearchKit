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
        should_skip = False
        try:
            with open(self.path, "r+") as file:
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

    def remove_internal_flags_and_content(self):

        start_delimeter = "#if RK_APPLE_INTERNAL"
        mid_delimiter = "#else"
        end_delimeter = "#endif"

        try:
            with open(self.path, "r+") as file:
                should_skip = False
                is_else_block_content = False
                new_content = []
                for line in file.readlines():

                    # begin skipping lines once the start_delimeter is found
                    if start_delimeter in line:
                        should_skip = True

                    # turn is_else_block_content false if we hit a end_delimeter
                    if end_delimeter in line and is_else_block_content:
                        is_else_block_content = False

                    if not should_skip or is_else_block_content:
                        new_content.append(line)

                    # if mid_delimiter is found begin collecting lines until end_delimeter is hit
                    if mid_delimiter in line:
                        is_else_block_content = True

                    if end_delimeter in line:
                        should_skip = False
                        is_else_block_content = False

                new_content = "".join(new_content)
                file.truncate(0)
                file.seek(0)
                file.write(new_content)

        except:
            print(f"Warning: Unable to open or write to file {self.path}")

class FileHelper(object):

    def recursively_read_files(self, project_path):
        all_files = []
        for root, _, files in os.walk(project_path):
            if ".git" not in root:
                for name in files:
                    if name != os.path.basename(__file__) \
                        and ".png" not in name \
                        and ".jpg" not in name:

                        path = os.path.join(root, name)
                        all_files.append(File(path))

        return all_files

    def fetch_files_to_delete(self, files, files_to_delete):
        collected_files = []

        for f in files:
            if f.name in files_to_delete:
                collected_files.append(f)

        return collected_files

    def fetch_files_with_special_comment(self, files):
        special_comment = "apple-internal"
        return [f for f in files if f.contains_text(special_comment)]

    def fetch_folders_to_delete(self, project_path, folders_to_delete):
        collected_folders = []
        for root, folders, _ in os.walk(project_path):
            for folder in folders:
                    if self.__is_a_folder_to_delete(folder, folders_to_delete):
                        path = os.path.join(root, folder)
                        collected_folders.append(path)

        return collected_folders

    def gather_files_from_internal_folders(self, folders):
        internal_files = []

        for folder in folders:
            internal_files = internal_files + self.__fetch_files_from_folder(folder)

        return internal_files

    def remove_file_references_from_project_file(self, file_path, files_to_delete):
        print(f"=== Removing files from pbxproj file ===")

        pbx_file = File(file_path)
        for f in files_to_delete:
            print(f"Removing lines containing name: {f.name}")
            pbx_file.remove_lines_containing(f.name)

        print(f"=== Finished Removing files from pbxproj file ===")

    def remove_internal_blocks_from_files(self, files):
        print(f"=== Removing enclosed internal code and references from files ===")
        for f in files:
            start_comment = "start-omit-internal-code"
            end_comment = "end-omit-internal-code"
            f.remove_internal_code(start_delimeter=start_comment, end_delimeter=end_comment)
            f.remove_internal_flags_and_content()
            f.remove_lines_containing("swiftlint")
            f.remove_lines_containing("// TODO:")
            f.remove_lines_containing("// FIXME:")
            f.remove_lines_containing("rdar://")
        print(f"=== Finished removing enclosed internal code and references from files ===")

    def delete_files(self, files_to_delete):
        print(f"=== Deleting all idenitified internal files ===")
        for f in files_to_delete:
            f.delete()
            print(f"\tDeleted file {f.name}")
        print(f"=== Finished deleting all idenitified internal files ===")

    def delete_folders(self, folders_to_delete):
        print(f"=== Deleting all idenitified internal folders ===")
        for folder in folders_to_delete:
            if os.path.exists(folder):
                rmtree(folder)
                print(f"\tDeleted folder {folder}")
        print(f"=== Finished deleting all idenitified internal references ===")

    def __is_a_folder_to_delete(self, current_folder, folders_to_delete):

        for folder in folders_to_delete:
            if folder == current_folder:
                return True

        return False

    def __fetch_files_from_folder(self, folder_path):
        filelist = []

        for root, dirs, files in os.walk(folder_path):

        	for file in files:
                #append the file name to the list
        		filelist.append(File(os.path.join(root,file)))

        return filelist

class RKScrubber():

    def __init__(self):
        self.file_helper = FileHelper()
        self.project_path = "../ResearchKit"
        self.tests_project_path = "../ResearchKitTests"
        self.core_project_path = "../ResearchKitCore"
        self.project_file_path = "../ResearchKit.xcodeproj/project.pbxproj"
        self.folders_to_remove = ["PrivateHeaders", "ORKAVJournaling", "ORKFaceDetectionStep", "Tinnitus", "ORKVolumeCalibration", "HeadphoneDetectStep", "InternalPredefinedTasks", "BLE", "MathUtilities", "Scrubbers"]

    def scrub_project(self):

        folders_to_delete = self.file_helper.fetch_folders_to_delete(self.project_path, self.folders_to_remove)
        files_to_delete = self.file_helper.gather_files_from_internal_folders(folders_to_delete)

        # gather all files from project
        files = self.file_helper.recursively_read_files(self.project_path) + self.file_helper.recursively_read_files(self.tests_project_path) + self.file_helper.recursively_read_files(self.core_project_path)

        files_with_special_comment = self.file_helper.fetch_files_with_special_comment(files)

        # combine files with special comment with files fetched from internal folders
        files_to_delete = files_to_delete + files_with_special_comment

        self.file_helper.remove_file_references_from_project_file(self.project_file_path, files_to_delete)
        self.file_helper.remove_internal_blocks_from_files(files)
        self.file_helper.delete_files(files_to_delete)
        self.file_helper.delete_folders(folders_to_delete)

        print("Success!")

class RKTestScrubber():

    def __init__(self):
        self.file_helper = FileHelper()
        self.project_path = "../Testing/ORKTest"
        self.project_file_path = "../Testing/ORKTest/ORKTest.xcodeproj/project.pbxproj"
        self.folders_to_remove = ["List1", "PracticeList", "QuestionList1", "TinnitusSounds1"]
        self.json_files_to_remove = ["ORKAVJournalingStep.json", "ORKAVJournalingResult.json", "ORKAVJournalingPredefinedTask.json", "ORKTinnitusPredefinedTask.json", "ORKTinnitusUnit.json", "ORKTinnitusTypeStep.json", "ORKTinnitusTypeResult.json", "ORKTinnitusVolumeResult.json", "ORKTinnitusPureToneStep.json", "ORKTinnitusPureToneResult.json", "ORKTinnitusMaskingSoundStep.json", "ORKTinnitusMaskingSoundResult.json", "ORKTinnitusOverallAssessmentStep.json", "ORKTinnitusOverallAssessmentResult.json", "ORKBLEScanPeripheralsStep.json", "ORKBLEScanPeripheralsStepResult.json", "ORKSpeechInNoisePredefinedTask.json", "ORKHeadphoneDetectStep.json", "ORKHeadphoneDetectResult.json", "ORKHeadphonesRequiredCompletionStep.json", "ORKFaceDetectionStep.json", "ORKVolumeCalibrationStep.json", "ORKdBHLToneAudiometryCompletionStep.json"]

    def scrub_project(self):
        files = self.file_helper.recursively_read_files(self.project_path)

        json_files_to_delete = self.file_helper.fetch_files_to_delete(files, self.json_files_to_remove)

        self.file_helper.delete_files(json_files_to_delete)

        folders_to_delete = self.file_helper.fetch_folders_to_delete(self.project_path, self.folders_to_remove)

        files_to_delete = self.file_helper.gather_files_from_internal_folders(folders_to_delete)

        files_with_special_comment = self.file_helper.fetch_files_with_special_comment(files)

        files_to_delete = files_to_delete + files_with_special_comment

        self.file_helper.remove_file_references_from_project_file(self.project_file_path, files_to_delete)
        self.file_helper.remove_internal_blocks_from_files(files)
        self.file_helper.delete_files(files_to_delete)
        self.file_helper.delete_folders(folders_to_delete)

class RKCatalogScrubber():
    def __init__(self):
        self.file_helper = FileHelper()
        self.project_path = "samples/ORKCatalog"
        self.project_file_path = "../samples/ORKCatalog/ORKCatalog.xcodeproj/project.pbxproj"
        self.folders_to_remove = ["Scrubbers", "List1", "PracticeList", "QuestionList1", "TinnitusSounds1","promo_image.imageset", "InternalUITests"]

    def scrub_project(self):
        files = self.file_helper.recursively_read_files(self.project_path)

        folders_to_delete = self.file_helper.fetch_folders_to_delete(self.project_path, self.folders_to_remove)

        files_to_delete = self.file_helper.gather_files_from_internal_folders(folders_to_delete)

        files_with_special_comment = self.file_helper.fetch_files_with_special_comment(files)

        files_to_delete = files_to_delete + files_with_special_comment

        self.file_helper.remove_file_references_from_project_file(self.project_file_path, files_to_delete)
        self.file_helper.remove_internal_blocks_from_files(files)
        self.file_helper.delete_files(files_to_delete)
        self.file_helper.delete_folders(folders_to_delete)

class RKIllegalTermsFinder():
    def __init__(self):
        self.project_path = "../ResearchKit"
        self.illegal_terms_to_check = ["apple_internal", "RK_APPLE_INTERNAL" ,"spi", "lime", "olive", "nectarine","secret","DEVEOPMENT_TEAM"]

    def find_illegal_terms(self):
        for term in self.illegal_terms_to_check:
            print("Searching RK for - ", term)
            grep_command = '''
             grep -HRn --ignore-case '{0}' {1}
            '''.format(term, self.project_path)
            output_stream = os.popen(grep_command)
            print(output_stream.read())


if __name__ == "__main__":

    # === SCRUB RK PROJECT OF INTERNAL CODE AND REFERENCES ===
    rk_scrubber = RKScrubber()
    rk_scrubber.scrub_project()

    # === SCRUB ORKTest PROJECT OF INTERNAL CODE AND REFERENCES ===
    rk_test_scrubber = RKTestScrubber()
    rk_test_scrubber.scrub_project()

    # === SCRUB ORKCatalog PROJECT OF INTERNAL CODE AND REFERENCES ===
    rk_catalog_scrubber = RKCatalogScrubber()
    rk_catalog_scrubber.scrub_project()

    # === GREP all illegal terms  ===
    rk_illegal_terms_finder = RKIllegalTermsFinder()
    rk_illegal_terms_finder.find_illegal_terms()
