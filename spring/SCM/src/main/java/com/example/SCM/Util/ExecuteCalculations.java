package com.example.SCM.Util;

import com.example.SCM.entity.OrderLineItem;
import com.example.SCM.enumClass.ServiceType;
import java.util.List;

public class ExecuteCalculations {

    private ExecuteCalculations() {
        throw new UnsupportedOperationException("This is a utility class and cannot be instantiated");
    }


    public static double calculateDeliveryCharge(double weight, ServiceType serviceType, double codAmount) {
        double base = 0;
        double perKg = 0;
        double charge = 0;

        if (serviceType != null) {
            switch (serviceType) {
                case STANDARD -> { base = 60; perKg = 20; }
                case EXPRESS -> { base = 100; perKg = 35; }
                case OVERNIGHT -> { base = 180; perKg = 50; }
                case SAME_DAY -> { base = 250; perKg = 60; }
            }
        }

        if (weight < 1) {
            charge = base;
        } else {
            charge = base + ((weight - 1) * perKg);
        }

        if (codAmount > 0) {
            charge += codAmount * 0.015;
        }

        return charge;
    }


    public static double calculateLineTotal(int quantity, double unitPrice) {
        return quantity * unitPrice;
    }


    public static double calculateItemSubtotal(List<OrderLineItem> lineItems) {
        if (lineItems == null) return 0.0;
        return lineItems.stream()
                .mapToDouble(OrderLineItem::getLineTotal)
                .sum();
    }


    public static double calculateTotalOrderWeight(List<OrderLineItem> lineItems) {
        if (lineItems == null) return 0.0;
        return lineItems.stream()
                .mapToDouble(OrderLineItem::getItemWeightTotal)
                .sum();
    }


    public static String calculatePaidAmount(double totalAmount, double codAmount) {
        double calculatedPaid = totalAmount - codAmount;
        return String.format("%.2f", calculatedPaid); // e.g., "8182.50"
    }
}