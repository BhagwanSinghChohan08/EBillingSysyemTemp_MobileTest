using EBillingSystemTemp.Model;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EBillingSystemTemp
{
    public partial class SacnBarcode : System.Web.UI.Page
    {
        ProductInfo obj = new ProductInfo();
        DataTable dtTemp = new DataTable();

        protected void Page_Load(object sender, EventArgs e)
        {
            //if (Request.UrlReferrer == null)
            //    Response.Redirect("SacnBarcode.aspx");

            HideShowDivs(0, 1, 1, 1, 1, 1, 1);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string beep = string.Empty;
            string barcode = txtBarcode.Text.Trim();

            if (!string.IsNullOrEmpty(barcode))
            {
                DataTable dtProduct = obj.GetProductByBarcode(barcode);                         

                if (dtProduct != null && dtProduct.Rows.Count > 0)
                {
                    DataTable dtScanedItems = obj.GetProductForAddBilling(barcode);

                    dtTemp = (DataTable)ViewState["ScannedItems"];
                    if (dtTemp != null && dtTemp.Rows.Count > 0)
                    {
                        var existRow = dtTemp.AsEnumerable().FirstOrDefault(r => r.Field<long>("ProductId") == Convert.ToInt64(dtScanedItems.Rows[0]["ProductId"]));

                        if (existRow == null)
                        {
                            DataRow newRow = dtTemp.NewRow();
                            newRow["Id"] = dtTemp.Rows.Count + 1;
                            newRow["ProductId"] = dtScanedItems.Rows[0]["ProductId"];
                            newRow["ProductName"] = dtScanedItems.Rows[0]["ProductName"];
                            newRow["ProductDesc"] = dtScanedItems.Rows[0]["ProductDesc"];
                            newRow["Qty"] = dtScanedItems.Rows[0]["Qty"];
                            newRow["HSNCode"] = dtScanedItems.Rows[0]["HSNCode"];
                            newRow["Price"] = dtScanedItems.Rows[0]["Price"];
                            newRow["TotalAmount"] = dtScanedItems.Rows[0]["TotalAmount"];
                            dtTemp.Rows.Add(newRow);
                        }
                    }
                    else
                    {
                        DataTable dt = createDT();

                        DataRow newRow = dt.NewRow();
                        newRow["Id"] = 1;
                        newRow["ProductId"] = dtScanedItems.Rows[0]["ProductId"];
                        newRow["ProductName"] = dtScanedItems.Rows[0]["ProductName"];
                        newRow["ProductDesc"] = dtScanedItems.Rows[0]["ProductDesc"];
                        newRow["Qty"] = dtScanedItems.Rows[0]["Qty"];
                        newRow["HSNCode"] = dtScanedItems.Rows[0]["HSNCode"];
                        newRow["Price"] = dtScanedItems.Rows[0]["Price"];
                        newRow["TotalAmount"] = dtScanedItems.Rows[0]["TotalAmount"];
                        dt.Rows.Add(newRow);

                        dtTemp = dt;
                    }

                    ViewState["ScannedItems"] = dtTemp;

                    if (dtTemp != null && dtTemp.Rows.Count > 0)
                    {
                        dtScannedProduts.DataSource = dtTemp;
                        dtScannedProduts.DataBind();
                        HideShowDivs(0, 0, 1, 1, 1, 1, 1);
                        beep = @" var audio = new Audio('/Audio/Beep_Beep_Success.mp3');  audio.play(); ";
                    }

                    decimal totalAmount = dtTemp.AsEnumerable().Sum(row => row.Field<decimal>("TotalAmount"));
                    string amnt = $"Total Amount: {totalAmount:C}";
                }
                else
                {
                    lblPNameError.Text = "Product not found!";
                    txtBarcodeNo.Text = barcode;
                    txtProductName.Focus();
                    HideShowDivs(0, 0, 0, 1, 1, 1, 1);
                    beep = @" var audio = new Audio('/Audio/Beep_Beep_Failed.mp3');  audio.play(); ";
                }

                ClientScript.RegisterStartupScript(this.GetType(), "PlayBeeps", beep, true);
                ClientScript.RegisterStartupScript(this.GetType(), "OpenCameraScript", "openCamera();", true);
            }
            else
            {
                lblPNameError.Text = "Please enter a barcode!";
            }
        }

        protected void btnAddProduct_Click(object sender, EventArgs e)
        {
            HideShowDivs(1, 1, 1, 0, 1, 1, 1);
        }

        private void HideShowDivs(int divFirst, int divSec, int divThird, int divFour, int divFifth, int divSix, int divSeven)
        {
            DivScanBarcode.Visible = 0 == divFirst;            /* <!-- Scan Barcode Section --> */
            DivProductDetails.Visible = 0 == divSec;            /* <!-- Product Details Section --> */
            DivError.Visible = 0 == divThird;                   /* <!-- Error Section --> */
            DivAddProduct.Visible = 0 == divFour;               /* <!-- Add Product Section --> */
            DivReports.Visible = 0 == divFifth;                 /* <!-- Reports Section --> */
        }

        protected void btnSaveProduct_Click(object sender, EventArgs e)
        {
            string productName = txtProductName.Text.Trim();
            string description = txtPDescription.Text.Trim();
            string barcode = txtBarcodeNo.Text.Trim();
            double price = string.IsNullOrEmpty(txtPPrice.Text.Trim()) ? 0 : Convert.ToDouble(txtPPrice.Text.Trim());

            if (string.IsNullOrEmpty(productName))
            {
                txtProductName.Focus();
                return;
            }

            DataTable dt = obj.SaveProductInfo(productName, description, barcode, price);
            if (dt != null && dt.Rows.Count > 0)
            {

            }
        }

        protected void btnReturn_Click(object sender, EventArgs e)
        {
            HideShowDivs(0, 1, 1, 1, 1, 1, 1);
        }

        private DataTable createDT()
        {
            DataTable tempDt = new DataTable();
            tempDt.Columns.Add("Id", typeof(long));
            tempDt.Columns.Add("ProductId", typeof(long));
            tempDt.Columns.Add("ProductName", typeof(string));
            tempDt.Columns.Add("ProductDesc", typeof(string));
            tempDt.Columns.Add("Qty", typeof(decimal));
            tempDt.Columns.Add("HSNCode", typeof(string));
            tempDt.Columns.Add("Price", typeof(decimal));
            tempDt.Columns.Add("TotalAmount", typeof(decimal));

            return tempDt;
        }
    }
}