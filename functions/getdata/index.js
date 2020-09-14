const log  = require('/opt/helpers/logger').logger;
const validator = require('/opt/helpers/validator');

var AWS = require('aws-sdk');
var dbClient = new AWS.DynamoDB.DocumentClient({convertEmptyValues: true});

exports.lambdaHandler = async (event, context) => {
    try {

        log.info('Checking event....');
        if(!event) throw new Error('Event not found!');

    } catch (error) {
        console.error(error);
    }
}
