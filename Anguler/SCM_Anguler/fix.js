const fs = require('fs');
const file = 'src/app/component/dashboard/procurement-dashboard/procurement-dashboard.component.ts';
let content = fs.readFileSync(file, 'utf8');

// 1. Add import
if (!content.includes('import { POLineItemComponent }')) {
    content = content.replace(
        "import { DashboardSettingsComponent } from '../dashboard-settings/dashboard-settings.component';",
        "import { DashboardSettingsComponent } from '../dashboard-settings/dashboard-settings.component';\nimport { POLineItemComponent } from '../../features/poline-item.component/poline-item.component';"
    );
}

// 2. Add to imports array
if (!content.includes('POLineItemComponent]')) {
    content = content.replace(
        "imports: [CommonModule, FormsModule, RouterModule, DashboardSettingsComponent],",
        "imports: [CommonModule, FormsModule, RouterModule, DashboardSettingsComponent, POLineItemComponent],"
    );
}

// 3. Add the methods and properties
const methodsToAdd = `
  showPoLineItemTable: boolean = false;
  
  get pendingPoLineItemsCount(): number {
    return this.rawPoLineItems ? this.rawPoLineItems.filter((item: any) => item.status === 'PENDING').length : 0;
  }

  togglePoLineItemTable() {
    this.showPoLineItemTable = !this.showPoLineItemTable;
  }
`;

if (!content.includes('showPoLineItemTable: boolean = false;')) {
    content = content.replace(
        "openTrackingModal() {",
        methodsToAdd + "\n  openTrackingModal() {"
    );
}

fs.writeFileSync(file, content, 'utf8');
