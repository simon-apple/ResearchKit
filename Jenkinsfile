def lib = library (
    identifier: 'lime-jenkins-shared-lib@version/1',
    retriever: modernSCM([
        $class: 'GitSCMSource',
        remote: 'git@github.pie.apple.com:HDS/lime-jenkins-shared-lib.git',
        credentialsId: '68bebe4a-a907-4e02-b67a-82ca3796b8bb'
    ])
)

node('ResearchApp-status') {
    stage('Set Environment Variables') {
        limeInitEnvironmentVariables(this, "ResearchKit Unit Tests", "AzulE169HunterET174", "HealthSPG/ResearchKit")
        limeSetBuildStatus(this, "PENDING")
    }
}

pipeline {
    agent { label "${LIME_BUILD_LABEL}" }
    options {
        // https://github.com/jenkinsci/jenkins/blob/master/core/src/main/java/hudson/tasks/LogRotator.java#L87
        buildDiscarder(
            logRotator(
                daysToKeepStr: env.LIME_KEEP_BUILDS_DAYS,
                numToKeepStr: env.LIME_KEEP_BUILDS_COUNT,
                artifactDaysToKeepStr: env.LIME_KEEP_ARTIFACTS_DAYS,
                artifactNumToKeepStr: env.LIME_KEEP_ARTIFACTS_COUNT))
    }
    stages {
        stage('Environment Setup') {
            steps {
                limeSetupXcode(this, [
                    "iPhone (Latest iOS)"
                ])
                limePrepareOutput(this)
            }
        }
        stage('Build for Testing (ResearchKit - Latest iOS)') {
            steps {
                timeout(time: 20, unit: 'MINUTES') {
                    sh 'set -o pipefail && xcodebuild clean build-for-testing -project ./ResearchKit.xcodeproj -scheme "ResearchKit" -destination "name=iPhone (Latest iOS)" | tee output/ResearchKit_Latest_iOS_build.log | /usr/local/bin/xcpretty'
                }
            }
        }
        stage('Test (ResearchKit - Latest iOS)') {
            steps {
                timeout(time: 20, unit: 'MINUTES') {
                    sh 'set -o pipefail && xcodebuild test-without-building -project ./ResearchKit.xcodeproj -scheme "ResearchKit" -destination "name=iPhone (Latest iOS)" -resultBundlePath output/ResearchKit/ios/RKTestResult | tee output/ResearchKit_Latest_iOS_test.log | /usr/local/bin/xcpretty -r junit'
                    sh 'set -o pipefail && xcrun xccov view --report --json output/ResearchKit/ios/RKTestResult.xcresult > output/ResearchKit/ios/CodeCoverage.json'
                    // sh 'set -o pipefail && swift ./scripts/xccov-json-to-cobertura-xml.swift output/ResearchKit/ios/CodeCoverage.json -targetsToExclude ResearchKitTests.xctest > output/ResearchKit/ios/CoberturaCodeCoverage.xml'
                }
            }
        }
        stage('Build for Testing (ORKTest - Latest iOS)') {
            steps {
                timeout(time: 20, unit: 'MINUTES') {
                    sh 'set -o pipefail && xcodebuild clean build-for-testing -project ./Testing/ORKTest/ORKTest.xcodeproj -scheme "ORKTest" -destination "name=iPhone (Latest iOS)" | tee output/ORKTest_Latest_iOS_build.log | /usr/local/bin/xcpretty'
                }
            }
        }
        stage('Test (ORKTest - Latest iOS)') {
            steps {
                timeout(time: 20, unit: 'MINUTES') {
                    sh 'set -o pipefail && xcodebuild test-without-building -project ./Testing/ORKTest/ORKTest.xcodeproj -scheme "ORKTest" -destination "name=iPhone (Latest iOS)" -resultBundlePath output/ResearchKit/ios/ORKTestResult | tee output/ORKTest_Latest_iOS_test.log | /usr/local/bin/xcpretty -r junit'
                }
            }
        }
    }
    post {
        always {
            limeArchiveOutput(this)
            junit 'build/reports/*.xml'
            // cobertura autoUpdateHealth: false, autoUpdateStability: false, coberturaReportFile: 'output/ResearchKit/ios/CoberturaCodeCoverage.xml', failUnhealthy: false, failUnstable: false, maxNumberOfBuilds: 0, onlyStable: false, sourceEncoding: 'ASCII', zoomCoverageChart: false
        }
        cleanup {
            script {
                limeSetBuildStatus(this, null)
                limeHandleEmail(this, "RKCK_Engineering@group.apple.com")
            }
        }
    }
}
