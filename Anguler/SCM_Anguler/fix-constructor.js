const fs = require('fs');
const file = 'src/app/component/dashboard/procurement-dashboard/procurement-dashboard.component.ts';
let content = fs.readFileSync(file, 'utf8');

if (!content.includes('private reqService: ProductRequirementService')) {
    content = content.replace(
        "private poLineItemService: PoLineItemService",
        "private poLineItemService: PoLineItemService,\n      private reqService: ProductRequirementService"
    );
    fs.writeFileSync(file, content, 'utf8');
}
