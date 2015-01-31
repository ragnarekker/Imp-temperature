local thingspeakUrl = "https://api.thingspeak.com/update";
local temp_field = "field3";
local volt_field = "field4";
local key = "my-thingspeak-key";

device.on("imp3_temp", function(temp) {
    // sleep for 5 sec so the log entry aligns
    imp.sleep(5);
    local request = http.get(thingspeakUrl+"?key="+key+"&"+temp_field+"="+temp);
    local response = request.sendsync();
    server.log("imp3_temp  ----  " + response.body + "  ----  " + temp);
    while (response.body == "0"){
        imp.sleep(20);
        request = http.get(thingspeakUrl+"?key="+key+"&"+temp_field+"="+temp);
        response = request.sendsync();
        server.log("imp3_temp  ----  " + response.body + "  ----  " + temp);
    }
});

device.on("imp3_volt", function(volt) {
    // ThingSpeak.com has a rate limit of an update per channel every 15 seconds.
    imp.sleep(20);
    local request = http.get(thingspeakUrl+"?key="+key+"&"+volt_field+"="+volt);
    local response = request.sendsync();
    server.log("imp3_volt  ----  " + response.body + "  ----  " + volt);    
    while (response.body == "0"){
        imp.sleep(20);
        request = http.get(thingspeakUrl+"?key="+key+"&"+volt_field+"="+volt);
        response = request.sendsync();
        server.log("imp3_volt  ----  " + response.body + "  ----  " + volt);
    }
});