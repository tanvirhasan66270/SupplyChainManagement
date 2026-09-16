package com.example.SCM.dto.request;



import lombok.Data;



@Data

public class OrderLineItemRequestDTO {

     private Long productId;

    private int quantity;

    private String remarks;

}