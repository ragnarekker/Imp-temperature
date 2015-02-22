// Variables unike for this agent
local temp_field = "field3";
local volt_field = "field4";
local temp_name = "imp3_temp"
local volt_name = "imp3_volt"


// ------- CODE BELOW IS THE SAME FOR THE IMP TO THINGSPEAK AGENTS ------- //

// Variables used in all imp to thingspeak agents
local theTemp = -99;
local theVolt = -99;
local thingspeakUrl = "https://api.thingspeak.com/update";
local key = "ECOET47B5R31CR58";

// This function handles pushing data to thingspeak.com and logs values
function sleepRequestLog(sleeptime, thingspeakUrl, key, field, value, log_name) {
    // ThingSpeak.com has a rate limit of an update per channel every 15 seconds.
    imp.sleep(sleeptime);
    local request = http.get(thingspeakUrl+"?key="+key+"&"+field+"="+value);
    local response = request.sendsync();
    server.log(log_name + "  ----  " + response.body + "  ----  " + value);
    return response;
}

device.on(temp_name, function(temp) {
    theTemp = temp;
    local response = sleepRequestLog(5, thingspeakUrl, key, temp_field, temp, temp_name);
    while (response.body == "0"){
        response = sleepRequestLog(20, thingspeakUrl, key, temp_field, temp, temp_name);
    }
});

device.on(volt_name, function(volt) {
    theVolt = volt;
    local response = sleepRequestLog(20, thingspeakUrl, key, volt_field, volt, volt_name);
    while (response.body == "0") {
        response = sleepRequestLog(20, thingspeakUrl, key, volt_field, volt, volt_name);
    }
});

// Values may be requested over http and this is the request handler
function request_handler(request, response) {
    try {
        if ("getTemp" in request.query) {
            response.send(200, theTemp);   
        } else if ("getVolt" in request.query) {
            response.send(200, theVolt);   
        } else {
            response.send(200, "OK - 200 - but no recognizable request");
        }
    }
    catch (ex) {
        response.send(500, ("Agent Error: " + ex)); // Send 500 response if error occured
    }
}

http.onrequest(request_handler);
