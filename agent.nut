local thingspeakUrl = "https://api.thingspeak.com/update";
local temp_field = "field1";
local volt_field = "field2";
local key = "my_thingspeak_key";

device.on("imp1_temp", function(temp) {
    imp.sleep(5);
    local request = http.get(thingspeakUrl+"?key="+key+"&"+temp_field+"="+temp);
    local response = request.sendsync();
    server.log("imp1_temp  ----  " + response.body + "  ----  " + temp)
});

device.on("imp1_volt", function(volt) {
    // ThingSpeak.com has a rate limit of an update per channel every 15 seconds.
    imp.sleep(20);
    local request = http.get(thingspeakUrl+"?key="+key+"&"+volt_field+"="+volt);
    local response = request.sendsync();
    server.log("imp1_volt  ----  " + response.body + "  ----  " + volt)
});
