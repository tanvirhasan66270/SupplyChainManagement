const fs = require('fs');
const file = 'src/app/component/dashboard/procurement-dashboard/procurement-dashboard.component.ts';
let content = fs.readFileSync(file, 'utf8');

const oldSubmitPr = `  submitPr() {
    this.prService.save(this.newPr).subscribe({`;

const newSubmitPr = `  submitPr() {
    this.newPr.productIds = this.selectedPrProducts.map(p => p.id);
    this.newPr.supplierIds = this.selectedPrSuppliers.map(s => s.id);
    
    // Encode requirements in remarks
    if (this.selectedPrRequirements && this.selectedPrRequirements.length > 0) {
      const reqNames = this.selectedPrRequirements.map(r => r.requirementName).join(', ');
      this.newPr.remarks = (this.newPr.remarks || '') + \` [Fulfilling Requirements: \${reqNames}]\`;
    }

    this.prService.save(this.newPr).subscribe({`;

content = content.replace(oldSubmitPr, newSubmitPr);
fs.writeFileSync(file, content, 'utf8');
