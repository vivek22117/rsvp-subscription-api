package com.subscription.api;

import com.amazonaws.auth.AWSCredentialsProvider;
import com.amazonaws.auth.InstanceProfileCredentialsProvider;
import com.amazonaws.auth.profile.ProfileCredentialsProvider;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.document.DynamoDB;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.Serializable;

import static com.subscription.api.PropertyLoader.getInstance;

public class AWSClientUtil implements Serializable {
    private static final Logger logger = LoggerFactory.getLogger(AWSClientUtil.class);
    Gson gson = new GsonBuilder().setPrettyPrinting().create();

    private static AWSCredentialsProvider awsCredentialsProvider;


    public static DynamoDB getDynamoDBClient() {
        try {
            awsCredentialsProvider = getAWSCredentialProvider();
            return new DynamoDB(AmazonDynamoDBClientBuilder.standard()
                    .withCredentials(awsCredentialsProvider)
                    .withRegion(Regions.US_EAST_1).build());

        } catch (Exception ex) {
            logger.error("Exception Occurred while creating DynamoDB client" + ex.getMessage(), ex);
        }
        return null;
    }

    private static AWSCredentialsProvider getAWSCredentialProvider() {

        if (awsCredentialsProvider == null) {
            boolean isRunningFromCI = Boolean.parseBoolean(getInstance().getPropertyValue("isRunningFromCI"));
            if (isRunningFromCI) {
                awsCredentialsProvider = new InstanceProfileCredentialsProvider(false);
            } else {
                awsCredentialsProvider = new ProfileCredentialsProvider("prod");
            }
        }
        return awsCredentialsProvider;
    }


}
