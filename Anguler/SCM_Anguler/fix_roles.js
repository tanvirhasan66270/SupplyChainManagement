const fs = require('fs');
const path = require('path');

const dir = "e:/spring/Spring-boot/Anguler/SCM_Anguler/src/app/component/dashboard";
const files = [
  "admin-dashboard/admin-dashboard.component.ts",
  "manager-dashboard/manager-dashboard.component.ts",
  "sales-dashboard/sales-dashboard.component.ts",
  "logistics-dashboard/logistics-dashboard.component.ts",
  "procurement-dashboard/procurement-dashboard.component.ts",
  "commercial-dashboard/commercial-dashboard.component.ts",
  "qc-inspector-dashboard/qc-inspector-dashboard.component.ts",
  "supplier-dashboard/supplier-dashboard.component.ts",
  "customer-dashboard.component/customer-dashboard.component.ts",
  "driver-dashboard/driver-dashboard.component.ts"
];

for (let file of files) {
  const fullPath = path.join(dir, file);
  if (!fs.existsSync(fullPath)) continue;
  let content = fs.readFileSync(fullPath, 'utf8');

  // We want to find `loadManager(): void {` or similar
  const match = content.match(/load(Manager|SalesOfficer|LogisticsOfficer|ProcurementOfficer|CommercialOfficer|QcInspector|Supplier|Customer|Driver)\(\)\s*:\s*void\s*\{/);
  
  if (match) {
    const roleName = match[1];
    if (roleName === 'Supplier') {
      content = content.replace(match[0], `${match[0]}\n    if (this.storage.getRole() === 'ADMIN') {\n      this.loadDashboardData(0);\n      return;\n    }`);
    } else if (roleName === 'Driver') {
       content = content.replace(match[0], `${match[0]}\n    if (this.storage.getRole() === 'ADMIN') {\n      this.loadDeliveryTrips();\n      return;\n    }`);
    } else {
      content = content.replace(match[0], `${match[0]}\n    if (this.storage.getRole() === 'ADMIN') return;`);
    }
    fs.writeFileSync(fullPath, content, 'utf8');
    console.log("Fixed", file);
  } else {
    console.log("No match in", file);
  }
}
