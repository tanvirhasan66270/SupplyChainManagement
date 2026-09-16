package com.example.SCM.enumClass;

public enum InvoiceStatus {
    DRAFT,     // যখন ইনভয়েসটি তৈরি হচ্ছে কিন্তু ফাইনাল করা হয়নি
    ISSUED,    // যখন ইনভয়েসটি ফাইনাল করে কাস্টমারকে পাঠানো হয়েছে (পেমেন্টের জন্য রেডি)
    CANCELLED  // যদি কোনো কারণে অর্ডার বাতিল বা ইনভয়েস রিভোক করা হয়
}