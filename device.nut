// pin 9 is the middle of the voltage divider formed by the NTC
//read the analog voltage to determine temperature
hardware.pin9.configure(ANALOG_IN);
// Pin 8 will work as ground. When it is on (high) it is the same as v_high and 
// no current flows. When low it is 0 and current flows through the thermistor
hardware.pin8.configure(DIGITAL_OUT);


// all calculations are done in Kelvin
const b_therm = 4400.0;
const t0_therm = 298.15;
local r0_therm = 81.3*1000;
local r_resist = 100.7*1000;


function getTemp() {
    // benchmarking: see how long thermistor is "on"
    local ton = hardware.micros();
    hardware.pin8.write(0);

    // gather several ADC readings and average them (just takes out some noise)
    thermPin <- hardware.pin9; 
    local val = 0;
    for (local i = 0; i < 10; i++) {
        imp.sleep(0.01);
        val += thermPin.read();
    }
    val = val / 10;
  
    // turn the thermistor circuit back off
    hardware.pin8.write(1);
    local toff = hardware.micros();

    // to read the battery voltage reliably, we take 10 readings and average them
    local v_high  = 0;
    for (local i = 0; i < 10; i++){
        imp.sleep(0.01);
        v_high += hardware.voltage();
    }
    v_high = v_high / 10.0;
  
    // Voltage drop over the thermistor. The thermistor is on the lower side of
    // resistiv devider. Voltage found from the ADC reading dividing by the 
    // full-scale value and multiplying by the supply voltage
    local v_therm = v_high * val / 65535.0;  
 
    // calculate the resistance of the thermistor at the current temperature
    local r_therm =  r_resist / ( v_high / v_therm  - 1);           // Lowside
    //local r_therm = (calcBatt[0]-v_therm)*(r_resist/v_therm);       // Highside
  
    // Calculate logarithmic term separate and find temprature in celcius
    local ln_therm = math.log(r0_therm / r_therm);
    local t_therm = (t0_therm * b_therm) / (b_therm - (t0_therm * ln_therm)) - 273.15;
  
    // Log stuff
    server.log(format("Thermistor Network on for %d us", (toff-ton)));
    server.log("v_high "+ v_high);
    server.log("b_therm "+ b_therm);
    server.log("t0_therm "+ t0_therm);
    server.log("r0_therm "+ r0_therm);
    server.log("r_resist "+ r_resist);
    server.log("v_therm "+ v_therm);
    server.log("r_therm "+ r_therm);
    server.log("ln_therm "+ ln_therm); 
    server.log("t_therm "+ t_therm);
  
    // Comunication with Agent
    agent.send("imp1_temp", t_therm);
    agent.send("imp1_volt", v_high);
  
    // Sleep for 5 minutes  
    imp.onidle(function() { server.sleepfor(300); });   
  
}

getTemp()