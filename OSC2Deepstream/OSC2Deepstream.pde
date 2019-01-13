import oscP5.*;
import netP5.*;
import io.deepstream.*;
import java.util.*;

import java.net.URISyntaxException;
import com.google.gson.*;

OscP5 oscP5;
DeepstreamClient deepstreamClient;

HashMap<String, String> oscMap = new HashMap();

void setup() {
    size(100, 100);
    oscMap.put("/ARIEL_Head$ARIEL", "body");
    oscMap.put("/C7_Thorax$C7", "body");
    oscMap.put("/LIHAND_L_Wrist$LIHAND", "body");
    oscMap.put("/RIHAND_R_Wrist$RIHAND", "body");
    oscMap.put("/T10_Thorax$T10", "body");
    oscMap.put("/RHEL_R_Foot$RHEL", "body");
    oscMap.put("/LHEL_L_Foot$LHEL", "body");
    oscMap.put("/LELB_L_Humerus$LELB", "body");
    

    oscP5 = new OscP5(this, 54321);

    try {
        deepstreamClient = new DeepstreamClient("wss://deepstream.glitch.me");
        println("Created Deepstream client");
    } 
    catch(URISyntaxException urise) {
        urise.printStackTrace();
        println(urise.getMessage());
    }

    deepstreamClient.setRuntimeErrorHandler(new DeepstreamRuntimeErrorHandler() {
        public void onException(io.deepstream.Topic t, io.deepstream.Event e, String error) {
            println(error);
        }
    }
    );

    LoginResult loginResult = deepstreamClient.login();
    println("Logged in to Deepstream: " + loginResult.loggedIn());

    /*
    Record record = deepstreamClient.record.getRecord("test-record");
     println(record.get());
     JsonObject data = new JsonObject();
     data.addProperty("name", "Alex");
     data.addProperty("favouriteDrink", "coffee");
     record.set(data);
     
     deepstreamClient.event.emit( "frame", data);*/
}

void draw() {
}

void oscEvent(OscBundle theBundle) {
    println("received a bundle", theBundle, theBundle.size());
    HashMap<String, JsonObject> jsonObjectsMap = new HashMap();
    for (OscMessage m : theBundle.get()) {
        //println("Processing message: ", m.getAddress());
        String objectName = oscMap.get(m.getAddress());
        if (objectName == null) continue;

        //println("Adding message to object: ", objectName);
        JsonObject jsonObject = jsonObjectsMap.get(objectName);
        if (jsonObject == null) {
            jsonObject = new JsonObject();
            jsonObject.add(objectName, new JsonObject());
            jsonObjectsMap.put(objectName, jsonObject);
        }

        JsonArray coords = new JsonArray();
        coords.add(m.get(0).floatValue());
        coords.add(m.get(1).floatValue());
        coords.add(m.get(2).floatValue());
        
        JsonObject inner = jsonObject.getAsJsonObject(objectName);
        inner.add(m.getAddress(), coords);
       
        
    }
    for (JsonObject jsonObject: jsonObjectsMap.values() ) {
        println(jsonObject);
        deepstreamClient.event.emit( "frame", jsonObject);
    }
}
/*
void oscEvent(OscMessage theOscMessage) {
 //println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
 //return;
 
 HashMap<String, JsonObject> jsonObjectsMap = new HashMap();
 
 if (theOscMessage.addrPattern().equals("/ARIEL_Head$ARIEL") ) {
 println("HEAD");
 JsonArray coords = new JsonArray();
 coords.add(theOscMessage.get(0).floatValue());
 coords.add(theOscMessage.get(1).floatValue());
 coords.add(theOscMessage.get(2).floatValue());
 JsonObject marker = new JsonObject();
 marker.add("ARIEL_Head$ARIEL", coords);
 
 //data.addProperty("favouriteDrink", "coffee");
 deepstreamClient.event.emit( "frame", marker);
 } else {
 // println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
 }
 }*/
