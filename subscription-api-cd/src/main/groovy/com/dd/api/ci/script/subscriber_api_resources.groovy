package com.dd.api.ci.script

import com.dd.api.ci.builder.SubscriberAPIResources


import javaposse.jobdsl.dsl.JobParent

def factory = this as JobParent
def listOfEnvironment = ["dev", "qa", "prod"]
def component = "subscriber-api-resources-job"

def emailId = "vivekmishra22117@gmail.com"
def description = "Pipeline DSL to create AWS resources for RSVP Subscription API"
def displayName = "RSVP Subscription API Resources Job"
def branchesName = "*/master"
def githubUrl = "https://github.com/vivek22117/rsvp-subscription-api.git"


new SubscriberAPIResources(
        dslFactory: factory,
        description: description,
        jobName: component + "-" + listOfEnvironment.get(0),
        displayName: displayName + " " + listOfEnvironment.get(0),
        branchesName: branchesName,
        githubUrl: githubUrl,
        credentialId: 'github',
        environment: listOfEnvironment.get(0),
        emailId: emailId

).build()


new SubscriberAPIResources(
        dslFactory: factory,
        description: description,
        jobName: component + "-" + listOfEnvironment.get(1),
        displayName: displayName + " " + listOfEnvironment.get(1),
        branchesName: branchesName,
        githubUrl: githubUrl,
        credentialId: 'github',
        environment: listOfEnvironment.get(1),
        emailId: emailId
).build()


new SubscriberAPIResources(
        dslFactory: factory,
        description: description,
        jobName: component + "-" + listOfEnvironment.get(2),
        displayName: displayName + " "+ listOfEnvironment.get(2),
        branchesName: branchesName,
        githubUrl: githubUrl,
        credentialId: 'github',
        environment: listOfEnvironment.get(2),
        emailId: emailId
).build()
