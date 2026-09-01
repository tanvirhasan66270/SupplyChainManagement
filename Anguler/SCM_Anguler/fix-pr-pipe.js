const fs = require('fs');
const file = 'src/app/component/dashboard/procurement-dashboard/procurement-dashboard.component.ts';
let content = fs.readFileSync(file, 'utf8');

const oldPrSub = `    this.prService.findAll().subscribe({
      next: (data) => {
        this.requisitions = data || [];
        this.approvedPRs = this.requisitions.filter(r => r.approvalStatus === 'APPROVED').length;
      }
    });`;

const newPrSub = `    this.prService.findAll().subscribe({
      next: (data) => {
        this.requisitions = (data || []).map((r: any) => {
          if (r.remarks) {
            const match = r.remarks.match(/\\[Fulfilling Requirements:\\s*(.*?)\\]/);
            if (match && match[1]) {
              r.productNames = r.productNames || [];
              match[1].split(',').forEach((reqName: string) => {
                r.productNames.push('[Req] ' + reqName.trim());
              });
            }
          }
          return r;
        });
        this.approvedPRs = this.requisitions.filter(r => r.approvalStatus === 'APPROVED').length;
      }
    });`;

content = content.replace(oldPrSub, newPrSub);
fs.writeFileSync(file, content, 'utf8');
