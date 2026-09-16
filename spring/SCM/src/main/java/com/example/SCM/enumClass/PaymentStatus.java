package com.example.SCM.enumClass;

public enum PaymentStatus {
    UNPAID,         // এখনও কোনো টাকা পেমেন্ট করা হয়নি (Paid Amount = 0)
    PARTIALLY_PAID, // কিছু অংশ পেমেন্ট করা হয়েছে তবে বকেয়া আছে (0 < Paid < Total)
    PAID,           // সম্পূর্ণ বিল পরিশোধ করা হয়েছে (Paid Amount >= Total)
    REFUNDED        // কাস্টমারকে টাকা ফেরত দেওয়া হয়েছে
}