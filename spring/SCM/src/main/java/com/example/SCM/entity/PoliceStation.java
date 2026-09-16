package com.example.SCM.entity;


import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "policestations")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PoliceStation {


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;        //  Mirpur
    private String nameBn;      // মিরপুর
    private String postalCode;  // 1216
    private Boolean active = true;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "district_id")
    private District district;


    @JsonIgnore
    @OneToMany(mappedBy = "policeStation")
    private List<User> users = new ArrayList<>();


}