const fs = require('fs');
const path = require('path');

const dashboardsDir = "e:/spring/Spring-boot/Anguler/SCM_Anguler/src/app/component/dashboard";

const dashboards = [
    ["admin-dashboard/admin-dashboard.component.html", "Admin", "Root Access | Full system control & oversight."],
    ["commercial-dashboard/commercial-dashboard.component.html", "Commercial Officer", "Financial metrics & commercial insights."],
    ["customer-dashboard.component/customer-dashboard.component.html", "Customer", "Track your orders & profile details."],
    ["driver-dashboard/driver-dashboard.component.html", "Driver", "Delivery trips & vehicle status."],
    ["logistics-dashboard/logistics-dashboard.component.html", "Logistics Officer", "Warehouse, inventory & logistics tracking."],
    ["manager-dashboard/manager-dashboard.component.html", "Manager", "Overall enterprise operations & approvals."],
    ["procurement-dashboard/procurement-dashboard.component.html", "Procurement", "Purchase, quotations & supplier management."],
    ["qc-inspector-dashboard/qc-inspector-dashboard.component.html", "QC Inspector", "Quality control & inspections."],
    ["supplier-dashboard/supplier-dashboard.component.html", "Supplier", "Purchase orders, shipments & invoices."]
];

const template = `  <div class="dashboard-header bg-white p-4 rounded-4 shadow-sm border mb-4 d-flex justify-content-between align-items-center">
    <div>
      <div class="d-flex align-items-center gap-2 mb-1">
        <h2 class="fw-bold text-dark fs-4 mb-0">Welcome back, <span class="text-primary">{{ userName }}</span> <span class="fs-4">👋</span></h2>
      </div>
      <p class="text-muted fs-8 mb-0 d-flex align-items-center gap-2">
        <span class="text-dark fw-bold">{role}</span> • {subtitle}
        <span class="badge bg-success bg-opacity-10 text-success rounded-pill px-2 py-1 fs-9"><span class="pulse-dot-green me-1"></span> Live</span>
      </p>
    </div>
    <div class="header-actions d-flex gap-2">
      <button class="btn btn-outline-secondary btn-sm px-3 fw-semibold rounded-3 d-flex align-items-center gap-1"><i class="bi bi-gear"></i></button>
      <button class="btn btn-outline-danger btn-sm px-3 fw-semibold rounded-3 d-flex align-items-center gap-1" (click)="logout()"><i class="bi bi-box-arrow-right"></i> Log Out</button>
    </div>
  </div>`;

for (let [relPath, role, subtitle] of dashboards) {
    const p = path.join(dashboardsDir, relPath);
    if (!fs.existsSync(p)) {
        console.log("NOT FOUND:", p);
        continue;
    }
    
    let content = fs.readFileSync(p, 'utf8');
    const headerHtml = template.replace('{role}', role).replace('{subtitle}', subtitle);
    
    // We want to replace the first major div inside the main container.
    // Let's use specific replacements based on the actual file content to be safe.
    
    if (relPath.includes("admin-dashboard")) {
        content = content.replace(/<div class="welcome-card[\s\S]*?<\/div>\s*<\/div>/, headerHtml);
    } else if (relPath.includes("commercial-dashboard")) {
        content = content.replace(/<div class="d-flex justify-content-between align-items-center mb-4[\s\S]*?<\/div>\s*<\/div>/, headerHtml);
    } else if (relPath.includes("customer-dashboard")) {
        content = content.replace(/<div class="welcome-card bg-white[\s\S]*?<\/div>\s*<\/div>\s*<\/div>\s*<\/div>/, headerHtml);
    } else if (relPath.includes("driver-dashboard")) {
        content = content.replace(/<div class="card border-0 shadow-sm p-4 rounded-4 bg-white mb-4[\s\S]*?<\/div>\s*<\/div>\s*<\/div>/, headerHtml);
    } else if (relPath.includes("logistics-dashboard")) {
        content = content.replace(/<div class="bg-white p-4 rounded-4 shadow-sm border-0 mb-4[\s\S]*?<\/div>\s*<\/div>\s*<\/div>\s*<\/div>/, headerHtml);
    } else if (relPath.includes("manager-dashboard")) {
        content = content.replace(/<div class="welcome-card p-4 rounded-4 shadow-sm border-0 mb-4[\s\S]*?<\/div>\s*<\/div>/, headerHtml);
    } else if (relPath.includes("procurement-dashboard")) {
        content = content.replace(/<div class="bg-white p-4 rounded-4 shadow-sm border mb-4[\s\S]*?<\/div>\s*<\/div>\s*<\/div>/, headerHtml);
    } else if (relPath.includes("qc-inspector-dashboard")) {
        content = content.replace(/<div class="bg-white p-4 rounded-4 shadow-sm border-0 mb-4[\s\S]*?<\/div>\s*<\/div>/, headerHtml);
    } else if (relPath.includes("supplier-dashboard")) {
        content = content.replace(/<div class="d-flex justify-content-between align-items-center bg-white[\s\S]*?<\/div>\s*<\/div>/, headerHtml);
    }
    
    fs.writeFileSync(p, content, 'utf8');
}
console.log("Second attempt complete");
