const fs = require('fs');
const file = 'src/app/component/dashboard/procurement-dashboard/procurement-dashboard.component.ts';
let content = fs.readFileSync(file, 'utf8');

const missingProps = `
  prRequirements: any[] = [];
  selectedPrRequirements: any[] = [];

  onPrRequirementSelect(event: any) {
    const val = event.target.value;
    const reqId = Number(val.includes(':') ? val.split(':')[1].trim().replace('REQ_', '') : val.replace('REQ_', ''));
    if (reqId) {
      const req = this.prRequirements.find(r => r.id === reqId);
      if (req && !this.selectedPrRequirements.some(r => r.id === reqId)) {
        this.selectedPrRequirements.push(req);
      }
    }
    // reset selection
    event.target.value = '';
  }

  removePrRequirement(id: number) {
    this.selectedPrRequirements = this.selectedPrRequirements.filter(r => r.id !== id);
  }
`;

if (!content.includes('prRequirements: any[] = [];')) {
    content = content.replace(
        "selectedPrProducts: any[] = [];",
        "selectedPrProducts: any[] = [];" + missingProps
    );
}

fs.writeFileSync(file, content, 'utf8');
