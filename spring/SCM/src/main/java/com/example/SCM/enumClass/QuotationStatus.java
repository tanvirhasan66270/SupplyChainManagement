package com.example.SCM.enumClass;

public enum QuotationStatus {
    // নতুন আপলোড করা কোটেশন, যা এখনো রিভিউ করা হয়নি
    PENDING,

    // কোটেশনটি বর্তমানে মূল্যায়নাধীন (Evaluation process)
    UNDER_REVIEW,

    // কোটেশনটি যাচাই-বাছাই শেষে গ্রহণ করা হয়েছে
    APPROVED,

    // কোটেশনটি বিভিন্ন কারণে বাতিল বা রিজেক্ট করা হয়েছে
    REJECTED,

    // কোটেশনের ভ্যালিডিটি ডেট (Valid Until) পার হয়ে গেছে, তাই এটি এখন অকার্যকর
    EXPIRED
}
