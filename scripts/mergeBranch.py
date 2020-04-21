#!/usr/bin/python
import os, sys, re, smtplib
from subprocess import Popen, PIPE
from pprint import pprint
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

BUILD_EMAIL_ADDRESS = "dr_zoidberg@apple.com"

def sendEmail(emailSubject, emailRecipients, ccRecipients, emailBody):
    sender = 'dr_zoidberg@apple.com'
    msg = MIMEMultipart('alternative')
    msg['From'] = sender
    msg['Subject'] = emailSubject
    msg['To'] = emailRecipients

    if ccRecipients != '':
        emailRecipients = emailRecipients + ',' + ccRecipients
        msg['Cc'] = ccRecipients

    plainPart = MIMEText(emailBody, 'plain')
    msg.attach(plainPart)
    mailServer = smtplib.SMTP('relay.aso.apple.com')
    mailServer.set_debuglevel(1)

    try:
        mailServer.sendmail(sender, emailRecipients.split(','), msg.as_string())
    finally:
        mailServer.quit()


def runCommand(command):
    print "Executing: " + ' '.join(command)
    child = Popen(command, stdout=PIPE, stderr=PIPE)
    (output, errors) = child.communicate()
    returnCode = child.returncode
    if returnCode:
        print 'Command returned non-zero status (%s):\n\n%s\n\nWith output:\n%sWith errors:\n\n%s' % (returnCode, command, output, errors)
        exit(returnCode)

    return output.rstrip()

CONFLICT_PAT = [
    # "CONFLICT (%s): Merge conflict in %s"
    re.compile(r'CONFLICT (?P<detail>\(.*\): Merge conflict in (?P<path>.*))'),
    # "CONFLICT (%s/delete): %s deleted in %s and %s in %s. Version %s of %s left in tree."
    # "CONFLICT (%s/delete): %s deleted in %s and %s in %s. Version %s of %s left in tree at %s."
    re.compile(r'CONFLICT (?P<detail>\(.*/delete\): (?P<path>.*) deleted in .* and .* in .*)\. Version '),
    # "CONFLICT (rename/add): Rename %s->%s in %s. %s added in %s"
    re.compile(r'CONFLICT (?P<detail>\(rename/add\): Rename .*->(?P<path>.*?) in .*)'),
    ]


def parse_conflict(text):
    path = '(unknown)'
    detail = text
    for pattern in CONFLICT_PAT:
        m = pattern.match(text)
        if m:
            path = m.group('path')
            detail = m.group('detail')
            break
    return path, detail


def get_conflicts(text):
    conflictLines = [line for line in text.splitlines() if line.startswith('CONFLICT (')]
    conflict_pathnames = []
    conflict_details = []
    for line in conflictLines:
        path, conflict = parse_conflict(line)
        conflict_pathnames.append(path)
        conflict_details.append(conflict)
    return conflict_pathnames, conflict_details


def get_initial_committer_email(log_message):

    email_address = None
    regex = re.compile("Scripted merge of ([0-9a-z]{40})")
    match = regex.match(log_message)

    if match is not None:
        print("Scripted merge detected...")
        merged_hash = match.group(1)

        cmd = ["git", "show", "--pretty=%ae", "--no-patch", merged_hash]
        email_address = runCommand(cmd)

        if email_address == BUILD_EMAIL_ADDRESS:
            cmd = ["git", "show", "--pretty=%B", "--no-patch", merged_hash]
            commit_message = runCommand(cmd)
            email_address = get_initial_committer_email(commit_message)

    return email_address


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='Merge two git branches iteratively one commit at a time. Run in the root directory of a git repository.')
    parser.add_argument('-repo', metavar='repo', required=True, help='Git repository to do the merge in.')
    parser.add_argument('-source', metavar='source', required=True, help='Branch to merge from.')
    parser.add_argument('-target', metavar='target', required=True, help='Branch to merge to.')
    parser.add_argument('-noemail', action='store_false', required=False, help='Turn off email notification')
    options = parser.parse_args()
    gitRepo = options.repo
    sourceBranch = options.source
    targetBranch = options.target
    sendNotification = options.noemail
    print 'Parsed arguments: -repo %s -source %s -target %s' % (gitRepo, sourceBranch, targetBranch)
    os.environ['TZ'] = 'America/Los_Angeles'
    baseDir = os.getcwd()

    remoteOutput = runCommand(['git', 'config', '--get', 'remote.origin.url'])
    if remoteOutput != gitRepo:
        print 'Error: Repository at %s is %s and does not match: %s' % (baseDir, remoteOutput, gitRepo)
        exit(1)

    print 'Updating repository and checking out branch: %s' % targetBranch
    runCommand(['git', 'clean', '-q', '-dxf'])
    runCommand(['git', 'reset', '-q', '--hard'])
    runCommand(['git', 'checkout', '-q', '%s' % sourceBranch])
    runCommand(['git', 'reset', '--hard', 'origin/%s' % sourceBranch])
    runCommand(['git', 'clean', '-q', '-dxf'])
    runCommand(['git', 'reset', '-q', '--hard'])
    runCommand(['git', 'checkout', '-q', '%s' % targetBranch])
    runCommand(['git', 'reset', '--hard', 'origin/%s' % targetBranch])
    runCommand(['git', 'submodule', 'init'])
    runCommand(['git', 'pull', '-q', '--rebase'])
    runCommand(['git', 'submodule', 'foreach', 'git', 'submodule', 'sync'])
    runCommand(['git', 'submodule', 'update', '--recursive'])

    # Custom 'git log' data and format
    logFields = ['hash', 'committer_name', 'committer_email', 'author_name', 'author_email', 'date', 'message']
    logFormat = ['%H', '%cn', '%ce', '%an', '%ae', '%ad', '%B']

    # Use ASCII field '\x1f' and record '\x1e' separators, which are probably not in data
    logFormat = '%x1f'.join(logFormat) + '%x1e'

    # Get the commits that need to be merged 'git log target..source' returns the commits in
    # the source branch that have not yet been merged to the target branch. And --pretty=oneline
    # shortens the log to to just the hash and commit message on one line
    #logOutput = runCommand(['git', 'log', '--format="%s"' % logFormat, '%s..%s' % (targetBranch, sourceBranch)])
    logChild = Popen('git log --first-parent --format="%s" %s..%s' % (logFormat, targetBranch, sourceBranch), shell=True, stdout=PIPE)
    (logOutput, logErrors) = logChild.communicate()
    logReturnCode = logChild.returncode

    if logReturnCode:
        print 'Command returned non-zero status (%s):\nWith errors:\n\n%s' % (logReturnCode, logErrors)
        exit(logReturnCode)

    if logOutput == '':
        print '\nNo commits found.\n'
        exit(0)

    logOutput = logOutput.strip('\x1e').split('\x1e')
    logOutput = [row.strip().split('\x1f') for row in logOutput]

    # Process each commit, but in reverse order since oldest is at the bottom
    logOutput.reverse()
    logOutput.pop(0) # pop off the first element, this is always just a newline

    print '\nFound (%d) commits to merge, in this order:' % len(logOutput)
    for log in logOutput:
        logDict = dict(zip(logFields, log))
        print '    (%s)' % logDict['hash']

    for log in logOutput:
        logDict = dict(zip(logFields, log))
        #print logDict
        # Make sure there is a hash, and merge it
        if logDict['hash']:
            commitHash = logDict['hash']
            emailSentFileName = '/tmp/sent_mergeBranch_email_%s_%s_%s' % (os.path.basename(sourceBranch),os.path.basename(targetBranch), commitHash)
            print '\nMerging commit: %s from %s (%s)' % (commitHash, logDict['author_name'], logDict['author_email'])

            # Check for "DO NOT MERGE" in commit string
            commitMessage = logDict['message']
            doNotMergePattern = re.compile('DO\sNOT\sMERGE', re.IGNORECASE)
            doNotMergeMatch = doNotMergePattern.findall(commitMessage)
            print 'Comment: %s' % commitMessage
            if doNotMergeMatch:
                print '\nLog: DO NOT MERGE found\n'
                # Commit was flagged as "DO NOT MERGE", so add "-s ours" to the merge command to skip any code changes, but record that the hash was merged with git
                mergeCommand = ['git', 'merge', '-s', 'ours', '--no-ff', '-mSKIPPED MERGE OF %s from branch %s. DO NOT MERGE' % (commitHash, sourceBranch), '%s' % commitHash]
            else:
                print '\nLog: DO NOT MERGE not found\n'
            # Merge the commit. Use --no-ff to always do a merge commit, even if a fast forward is possible
                mergeCommand = ['git', 'merge', '--no-ff', '-mScripted merge of %s from branch %s' % (commitHash, sourceBranch), '%s' % commitHash]

            merge = Popen(mergeCommand, stdout=PIPE, stderr=PIPE)
            (mergeOutput, mergeErrors) = merge.communicate()
            print mergeOutput
            mergeReturnCode = merge.returncode
            if mergeReturnCode:
                conflictMatch, conflictDetail = get_conflicts(mergeOutput)
                if conflictMatch:
                    conflicts = ''
                    if len(conflictMatch) == 1:
                        conflicts = 'Conflict found in file: \t' + conflictMatch[0]
                    else:
                        conflicts = 'Conflicts found in files:\n\n\t' + '\n\t'.join(conflictMatch)

                    emailSubject = 'Auto Merge %s from %s to branch %s failed in commit %s' % (gitRepo,sourceBranch, targetBranch, commitHash)
                    emailBody = 'The auto merge script encountered conflicts when attempting to merge one of your commits. Please read this email and take action.\n\n'
                    if os.environ.get('BUILD_URL'):
                        emailBody += 'Jenkins URL: %s.\n\n' % os.environ.get('BUILD_URL')
                    emailBody += 'IMPORTANT NOTE: The auto merge is held up until this conflict is resolved. It is also critical to use the commands below to do the merge.\n\n'
                    emailBody += 'repo: %s' % gitRepo + '\n'
                    emailBody += 'Source branch: %s' % sourceBranch + '\n'
                    emailBody += 'Target branch: %s' % targetBranch + '\n'
                    emailBody += '\n\nHash:\t' + logDict['hash'] + '\n'
                    emailBody += 'Author:\t' + logDict['author_name'] + '\n'
                    emailBody += 'Author Email:\t' + logDict['author_email'] + '\n'
                    emailBody += 'Committer:\t' + logDict['committer_name'] + '\n'
                    emailBody += 'Committer Email:\t' + logDict['committer_email'] + '\n'
                    emailBody += 'Date:\t' + logDict['date'] + '\n'
                    emailBody += 'Message:\n\n\t' + logDict['message'] + '\n\n' + conflicts
                    emailBody += '\n\nConflict details:\n\n\t'
                    emailBody += '\n\t'.join(conflictDetail)

                    emailBody += '\n\nPlease resolve the conflicts by running the following commands:\n\n'
                    emailBody += 'If you are using a PR:\n\n'
                    emailBody += '1. git clone %s (or use your existing up to date repo)' % gitRepo + '\n'
                    emailBody += '2. git checkout -b [personal branch name] origin/%s' % targetBranch + '\n'
                    emailBody += '3. git merge %s' % logDict['hash'] + '\n'
                    emailBody += '4. git add' + '\n'
                    emailBody += '5. git commit' + '\n'
                    emailBody += '6. git push origin [personal branch name]:[personal branch name]' + '\n'
                    emailBody += '7. Create a Pull Request using personal branch above.' + '\n'
                    emailBody += '\t' + '- Creating a PR will also kick off PR builds to verify the merge fix.' + '\n'
                    emailBody += '8. Merge PR using "Create a merge commit" method. DO NOT SQUASH MERGE' + '\n'

                    emailBody += '\n\nIf you DO NOT want to merge this commit then run the following commands:\n\n'
                    emailBody += '1. git clone %s (or use your existing up to date repo)' % gitRepo + '\n'
                    emailBody += '2. git checkout -b [personal branch name] origin/%s' % targetBranch + '\n'
                    emailBody += '3. git merge --no-ff %s -s ours -m"SKIPPING merge of %s from branch %s"' % (logDict['hash'], logDict['hash'], sourceBranch) + '\n'
                    emailBody += '4. git push origin [personal branch name]:[personal branch name]' + '\n'
                    emailBody += '5. Create a Pull Request using personal branch above.' + '\n'
                    emailBody += '\t' + '- Creating a PR will also kick off PR builds to verify the merge fix.' + '\n'
                    emailBody += '6. Merge PR using "Create a merge commit" method. DO NOT SQUASH MERGE' + '\n'
                    emailBody += 'This will make git think the commit was merged, but no code will change.\n\n'

                    emailBody += 'More details on the process here: https://quip-apple.com/VJKbAun4Gg9t\n'

                    # emailRecipients = logDict['committer_email']
                    emailRecipients = logDict['author_email']
                    ccRecipients = 'healthspg-frameworks@group.apple.com'

                    if logDict['committer_email'] == BUILD_EMAIL_ADDRESS and logDict['author_email'] == BUILD_EMAIL_ADDRESS:
                        print "Trying to find email address of initial committer..."
                        initial_committer_email = get_initial_committer_email(logDict['message'])
                        if initial_committer_email is not None:
                            print "Email address detected: %s" % initial_committer_email
                            ccRecipients += "," + initial_committer_email

                    print 'Flag file: %s' % emailSentFileName
                    if os.path.isfile(emailSentFileName):
                        print 'Found conflicts, but already sent email: %s' % emailSubject
                        print 'Remove file to have email sent again.'
                    else:
                        if sendNotification:
                            print 'Sending email to: %s with subject: %s' % (emailRecipients, emailSubject)
                            sendEmail(emailSubject, emailRecipients, ccRecipients, emailBody)
                        else:
                            print "Email notifications are disabled."
                        emailSentFile = open(emailSentFileName, "w")
                        emailSentFile.write(emailSubject + '\n\n' + emailRecipients + '\n\n' + emailBody)
                        emailSentFile.close()

                else:
                    print 'Merge failed with exit code: %s' % mergeOutput

                exit(mergeReturnCode)

            print 'Successfully merged: %s' % commitHash
            pushOutput = runCommand(['git', 'push', 'origin', '%s' % targetBranch])

            print pushOutput
