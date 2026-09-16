package com.example.SCM.enumClass;

public enum StockMovementType {
    INWARD,    // গুদামে মালামাল প্রবেশ (Receipt/GRN)
    OUTWARD,   // গুদাম থেকে মালামাল নির্গমন (Dispatch/Delivery)
    TRANSFER,  // এক গুদাম থেকে অন্য গুদামে স্থানান্তর
    ADJUSTMENT // স্টক সমন্বয় (চুরি বা নষ্টের কারণে স্টক ঠিক করা)
}