package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.QuotationMapper;
import com.example.SCM.dto.request.QuotationRequestDTO;
import com.example.SCM.repository.ProductRepository;
import com.example.SCM.repository.PurchaseRequisitionRepository;
import com.example.SCM.repository.QuotationRepository;
import com.example.SCM.repository.SupplierRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

@ExtendWith(MockitoExtension.class)
public class QuotationServiceImpTest {

    @Mock
    private QuotationRepository quotationRepository;
    @Mock
    private SupplierRepository supplierRepository;
    @Mock
    private ProductRepository productRepository;
    @Mock
    private PurchaseRequisitionRepository requisitionRepository;
    @Mock
    private QuotationMapper quotationMapper;

    @InjectMocks
    private QuotationServiceImp quotationService;

    private QuotationRequestDTO dto;

    @BeforeEach
    void setUp() {
        dto = new QuotationRequestDTO();
    }

    @Test
    void testSave_WhenSupplierIdIsNull_ThrowsIllegalArgumentException() {
        dto.setSupplierId(null);
        
        dto.setPurchaseRequisitionId(1L);

        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            quotationService.save(dto, null);
        });

        assertEquals("Supplier ID must not be null", exception.getMessage());
    }

    @Test
    void testSave_WhenProductIdIsNull_ThrowsIllegalArgumentException() {
        dto.setSupplierId(1L);

        dto.setPurchaseRequisitionId(1L);

        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            quotationService.save(dto, null);
        });

        assertEquals("Product ID must not be null", exception.getMessage());
    }

    @Test
    void testSave_WhenPurchaseRequisitionIdIsNull_ThrowsIllegalArgumentException() {
        dto.setSupplierId(1L);

        dto.setPurchaseRequisitionId(null);

        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            quotationService.save(dto, null);
        });

        assertEquals("Purchase Requisition ID must not be null", exception.getMessage());
    }
}
