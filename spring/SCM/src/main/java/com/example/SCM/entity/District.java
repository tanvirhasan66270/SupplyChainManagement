package com.example.SCM.entity;


import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "districts")
public class District {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;           // e.g. Gazipur
    private String nameBn;         // e.g. গাজীপুর
    private String districtCode;   // optional admin code
    private Boolean active = true;


    @JsonIgnore
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "division_id")
    private Division division;

    @JsonIgnore
    @OneToMany(mappedBy = "district", cascade = CascadeType.ALL)
    private List<PoliceStation> policeStations = new ArrayList<>();

}
