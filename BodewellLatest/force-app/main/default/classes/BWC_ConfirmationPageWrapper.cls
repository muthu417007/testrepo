public with sharing class BWC_ConfirmationPageWrapper {
    public String id { get; set; }
    public String name { get; set; }
    public String type { get; set; }
    public Integer quantity { get; set; }
    public Decimal salesPrice { get; set; }
    public Decimal adjustmentAmount { get; set; }
    public Decimal amount { get; set; }
    public Decimal listPrice { get; set; }
    public Decimal price { get; set; }
    public Decimal tax { get; set; }
    public Decimal unitAdjustedPrice { get; set; }
    public Decimal unitAdjustmentAmount { get; set; }
    public ProductDetails ProductDetails { get; set; }
    public PurchaseQuantityRule purchaseQuantityRule { get; set; }
    public String sku { get; set; }
    public ThumbnailImage thumbnailImage { get; set; }
    public String productId { get; set; }
    public Map<String, Object> variationAttributes { get; set; }
    

        public class ProductDsetails {
            public String name { get; set; }
            public Map<String, Object> fields { get; set; }
        }

        public class PurchaseQuantityRule {
            public Decimal increment { get; set; }
            public Decimal maximum { get; set; }
            public Decimal minimum { get; set; }
        }

        public class ThumbnailImage {
            public String alternateText { get; set; }
            public String contentVersionId { get; set; }
            public String id { get; set; }
            public String mediaType { get; set; }
            public Integer sortOrder { get; set; }
            public String thumbnailUrl { get; set; }
            public String title { get; set; }
            public String url { get; set; }
        }
}