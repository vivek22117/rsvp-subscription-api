var Validator = require('jsonschema').Validator
var v  = new Validator();

const getSubscriberSchema = {
    id: '/getSubscriber',
    type:'object',
    properties: {
        subscriber_arn: {type: 'string', minLength: 1},
    },
    required: ['subscriber_arn'],
};

const putDataSchema = {
    id: '/addSubscriber',
    type:'object',
    properties: {
        subscriber_arn: {type: 'string', minLength: 1},
        subscriber_type: {type: 'string', minLength: 1},
        resource_arn: {type: 'string', minLength: 1},
        resource_type: {type: 'string', minLength: 1},
        data_type: {type: 'string', minLength: 1},
    },
    required: ['subscriber_arn', 'subscriber_type', 'resource_arn', 'resource_type', 'data_type'],
};



v.addSchema(getSubscriberSchema, '/getSubscriber');
v.addSchema(putDataSchema, '/addSubscriber');


exports.validate = async (data, schema) => {
    const validationResult = v.validate(data, schema);
    const status = {};

    if(validationResult.errors.length > 0) {
        (status.result = 'invalid'), (status.errors = validationResult.errors.map((e) => e.stack.replace('instance', 'payload.')));
    } else {
        (status.result = 'valid'), (status.errors = []);
    }
    return status;
};