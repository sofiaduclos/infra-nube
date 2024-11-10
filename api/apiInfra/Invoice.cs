namespace apiInfra
{
    public class Invoice
    {
        public int Id { get; set; }

        public Double Amount { get; set; }

        public string Currency = "USD";

        public string? Description { get; set; }

        public DateTime Date { get; set; }
    }
}