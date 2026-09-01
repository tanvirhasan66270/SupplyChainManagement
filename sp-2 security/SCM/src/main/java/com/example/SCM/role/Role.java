package com.example.SCM.role;

public enum Role {

    ADMIN,
    MANAGER,
    DRIVER,
    PROCUREMENT,
    QC_INSPECTOR,
    LOGISTICS_OFFICER,
    COMMERCIAL_OFFICER,
    CUSTOMER,
    SUPPLIER,
    SALES_OFFICER;

    // Returns Spring Security compatible authority string
    public String getAuthority() {
        return "ROLE_" + this.name();
    }

}
