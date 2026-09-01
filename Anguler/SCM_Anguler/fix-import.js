const fs = require('fs');
const file = 'src/app/component/dashboard/procurement-dashboard/procurement-dashboard.component.ts';
let content = fs.readFileSync(file, 'utf8');

if (!content.includes('import { ProductRequirementService }')) {
    content = "import { ProductRequirementService } from '../../../service/product-requirement.service';\n" + content;
    fs.writeFileSync(file, content, 'utf8');
}
