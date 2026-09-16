package com.example.SCM.enumClass;


public enum PaymentIssueStatus {
    PENDING_VERIFICATION, // পেমেন্ট করা হয়েছে, ভেরিফিকেশন বাকি
    CONFIRMED_BY_OFFICER, // সেলস অফিসার বা অ্যাকাউন্টস দ্বারা কনফার্ম করা হয়েছে (কোম্পানি অ্যাকাউন্টে জমা হয়েছে)
    FAILED_OR_REJECTED    // পেমেন্ট ফেইল বা রিজেক্ট হয়েছে
}