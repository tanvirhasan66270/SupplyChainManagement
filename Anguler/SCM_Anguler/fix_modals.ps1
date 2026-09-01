$qFile = "src/app/component/features/quatation.component/quatation.component.html"
$qContent = Get-Content $qFile -Raw

$qContent = $qContent -replace '<div class="container-fluid py-4 px-4 text-dark">', '<div class="container-fluid py-4 px-4 text-dark" *ngIf="!isEmbedded">'

$qContent = $qContent -replace '<div class="drawer-body p-4" style="overflow-y: auto; height: calc\(100vh - 110px\);">\s*<form #qForm="ngForm" \(ngSubmit\)="qForm.valid && save\(\)">', '<div class="drawer-body p-4" style="overflow-y: auto; height: calc(100vh - 110px);">
      <ng-container *ngTemplateOutlet="quotationFormTemplate"></ng-container>'

$qContent = $qContent -replace 'Clear</button>\s*</div>\s*</form>\s*</div>', 'Clear</button>
        </div>
      </form>
</ng-template>
    </div>'

$qContent = $qContent -replace '<div class="modal-backdrop fade show" \*ngIf="isPdfModalOpen"></div>', '<div class="modal-backdrop fade show" *ngIf="isPdfModalOpen"></div>
</div>

<!-- MODAL: ADD QUOTATION (LC STYLE) -->
<div class="modal fade show d-block" tabindex="-1" style="background: rgba(15, 23, 42, 0.65); backdrop-filter: blur(8px); z-index: 1055;" *ngIf="isEmbedded">
  <div class="modal-dialog modal-dialog-centered modal-lg" style="max-width: 850px;">
    <div class="modal-content shadow-lg border-0 rounded-4 overflow-hidden bg-white animate-fade-in">
      <div class="modal-header px-4 py-3.5 border-0 d-flex justify-content-between align-items-center text-white" style="background: linear-gradient(135deg, #312e81 0%, #4338ca 60%, #6366f1 100%);">
        <div class="d-flex align-items-center gap-3">
          <div class="p-2.5 rounded-3 bg-white bg-opacity-20 backdrop-blur shadow-sm d-flex align-items-center justify-content-center" style="width: 44px; height: 44px;">
            <i class="bi bi-file-earmark-arrow-up fs-4 text-white"></i>
          </div>
          <div>
            <h5 class="modal-title fw-bold mb-0 text-white" style="letter-spacing: -0.01em;">Submit Quotation Bid</h5>
            <p class="text-white-50 small mb-0 fs-8">Provide pricing and timeline for corporate purchase requisitions</p>
          </div>
        </div>
        <button type="button" class="btn-close btn-close-white" (click)="closeDrawer()"></button>
      </div>
      <div class="modal-body p-4 bg-light custom-scroll overflow-auto" style="max-height: 580px;">
         <ng-container *ngTemplateOutlet="quotationFormTemplate"></ng-container>
      </div>
    </div>
  </div>
</div>'

Set-Content $qFile $qContent

$sFile = "src/app/component/features/shipment.component/shipment.component.html"
$sContent = Get-Content $sFile -Raw

$sContent = $sContent -replace '<div class="container-fluid py-4 px-4 text-dark">', '<div class="container-fluid py-4 px-4 text-dark" *ngIf="!isEmbedded">'

$sContent = $sContent -replace '<div class="modal-backdrop fade show" \*ngIf="isPdfModalOpen"></div>\s*<ng-template #shipmentFormTemplate>', '<div class="modal-backdrop fade show" *ngIf="isPdfModalOpen"></div>
</div>
<ng-template #shipmentFormTemplate>'

$sContent = $sContent -replace '<!-- MODAL: ADD SHIPMENT \(LC STYLE\) -->\s*<div class="modal fade show d-block" tabindex="-1" style="background: rgba\(15, 23, 42, 0.65\); backdrop-filter: blur\(8px\);" \*ngIf="isEmbedded">', '<!-- MODAL: ADD SHIPMENT (LC STYLE) -->
<div class="modal fade show d-block" tabindex="-1" style="background: rgba(15, 23, 42, 0.65); backdrop-filter: blur(8px); z-index: 1055;" *ngIf="isEmbedded">'

$sContent = $sContent -replace '</div>\s*</div>\s*</div>\s*</div>\s*$', '</div>
  </div>
</div>'

Set-Content $sFile $sContent
