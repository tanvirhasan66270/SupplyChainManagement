package com.example.SCM.Util.TrakingCode;


import org.springframework.stereotype.Service;

@Service
public class TrackingCodeGenerator {

    public static String generateTrackingCode() {

        return "TRN-" + System.currentTimeMillis();
    }

}
