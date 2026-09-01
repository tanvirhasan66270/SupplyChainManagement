import os
import re

dashboards_dir = "e:\\spring\\Spring-boot\\Anguler\\SCM_Anguler\\src\\app\\component\\dashboard"

dashboards = [
    ("admin-dashboard/admin-dashboard.component.html", "Admin", "Root Access | Full system control & oversight."),
    ("commercial-dashboard/commercial-dashboard.component.html", "Commercial Officer", "Financial metrics & commercial insights."),
    ("customer-dashboard.component/customer-dashboard.component.html", "Customer", "Track your orders & profile details."),
    ("driver-dashboard/driver-dashboard.component.html", "Driver", "Delivery trips & vehicle status."),
    ("logistics-dashboard/logistics-dashboard.component.html", "Logistics Officer", "Warehouse, inventory & logistics tracking."),
    ("manager-dashboard/manager-dashboard.component.html", "Manager", "Overall enterprise operations & approvals."),
    ("procurement-dashboard/procurement-dashboard.component.html", "Procurement", "Purchase, quotations & supplier management."),
    ("qc-inspector-dashboard/qc-inspector-dashboard.component.html", "QC Inspector", "Quality control & inspections."),
    ("supplier-dashboard/supplier-dashboard.component.html", "Supplier", "Purchase orders, shipments & invoices.")
]

def fix_sales_dashboard():
    path = os.path.join(dashboards_dir, "sales-dashboard/sales-dashboard.component.html")
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
        content = re.sub(r'<span class="fs-4">.*?</span>', '<span class="fs-4">👋</span>', content)
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)

fix_sales_dashboard()

template = '''  <div class="dashboard-header bg-white p-4 rounded-4 shadow-sm border mb-4 d-flex justify-content-between align-items-center">
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
  </div>'''

for rel_path, role, subtitle in dashboards:
    path = os.path.join(dashboards_dir, rel_path)
    if not os.path.exists(path):
        continue
    
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    header_html = template.format(role=role, subtitle=subtitle)
    
    if "admin-dashboard" in rel_path:
        content = re.sub(r'<div class="welcome-card.*?</div>\s*</div>', header_html, content, flags=re.DOTALL)
    elif "commercial-dashboard" in rel_path:
        content = re.sub(r'<!-- 1\. Top Title & Welcome -->\s*<div class="d-flex.*?</div>\s*</div>', f"<!-- 1. Top Title & Welcome -->\\n{header_html}", content, flags=re.DOTALL)
    elif "customer-dashboard" in rel_path:
        content = re.sub(r'<div class="welcome-card.*?</div>\s*</div>\s*</div>\s*</div>', header_html, content, flags=re.DOTALL)
    elif "driver-dashboard" in rel_path:
        content = re.sub(r'<!-- 1\. Header & Profile Section -->\s*<div class="card border-0.*?</div>\s*</div>\s*</div>', f"<!-- 1. Header & Profile Section -->\\n{header_html}", content, flags=re.DOTALL)
    elif "logistics-dashboard" in rel_path:
        content = re.sub(r'<!-- 1\. Modern Header & Quick Stats -->\s*<div class="bg-white.*?</div>\s*</div>\s*</div>\s*</div>', f"<!-- 1. Modern Header & Quick Stats -->\\n{header_html}", content, flags=re.DOTALL)
    elif "manager-dashboard" in rel_path:
        content = re.sub(r'<!-- 1\. Top Welcome & Actions -->\s*<div class="bg-white.*?</div>\s*</div>', f"<!-- 1. Top Welcome & Actions -->\\n{header_html}", content, flags=re.DOTALL)
    elif "procurement-dashboard" in rel_path:
        content = re.sub(r'<!-- 1\. Dashboard Header -->\s*<div class="bg-white.*?</div>\s*</div>\s*</div>', f"<!-- 1. Dashboard Header -->\\n{header_html}", content, flags=re.DOTALL)
    elif "qc-inspector-dashboard" in rel_path:
        content = re.sub(r'<!-- 1\. Header Section -->\s*<div class="bg-white.*?</div>\s*</div>', f"<!-- 1. Header Section -->\\n{header_html}", content, flags=re.DOTALL)
    elif "supplier-dashboard" in rel_path:
        content = re.sub(r'<!-- 1\. Header Section -->\s*<div class="d-flex.*?</div>\s*</div>', f"<!-- 1. Header Section -->\\n{header_html}", content, flags=re.DOTALL)
        
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

print("Headers updated successfully!")
