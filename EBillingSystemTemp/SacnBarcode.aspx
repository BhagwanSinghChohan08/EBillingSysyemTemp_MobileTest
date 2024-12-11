<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SacnBarcode.aspx.cs" Inherits="EBillingSystemTemp.SacnBarcode" %>

<!DOCTYPE html>
<html>
<head>
    <title>Scan Barcode</title>
    <link type="text/css" rel="stylesheet" href="Content/bootstrap.min.css" />
    <style type="text/css">
        .card-header {
            font-size: 1.25rem;
            font-weight: bold;
        }

        /* CSS for Caamera preview - Start */

        #cameraPreview {
            border: 1px solid #ccc;
            background: #000;
            height: auto;
            min-height: 300px; /* Ensure a minimum size */
            display: block;
        }

        #cameraContainer {
            height: 300px;
            overflow: hidden; /* Prevent content overflow */
            border: 2px solid #007bff; /* Highlight border */
            border-radius: 15px; /* Rounded corners */
            position: relative;
            background: #000; /* Dark background */
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* Shadow effect */
        }

        .camera-frame {
            position: relative;
            height: 100%;
        }

        #cameraPreview {
            height: 100%;
            object-fit: cover; /* Maintain aspect ratio */
            border-radius: 15px; /* Rounded corners for video */
        }

        .camera-overlay {
            background: rgba(0, 0, 0, 0.6); /* Transparent dark overlay */
            color: #fff;
            font-family: Arial, sans-serif;
            padding: 10px;
            border-radius: 10px;
        }

            .camera-overlay h5 {
                font-weight: bold;
                margin-bottom: 5px;
            }

            .camera-overlay p {
                font-size: 0.9rem;
                margin: 0;
                opacity: 0.9;
            }

        /* CSS for Caamera preview - End */
    </style>
    <script src="https://cdn.jsdelivr.net/npm/quagga@0.12.1/dist/quagga.min.js"></script>

    <%--<script type="text/javascript" src=""></script>--%>
    <script>
        let currentStream;

        function openCamera(useFrontCamera = false) {
            const cameraContainer = document.getElementById('cameraContainer');
            const cameraPreview = document.getElementById('cameraPreview');

            // Show the camera container
            cameraContainer.classList.remove('d-none');

            // Stop any existing camera stream
            if (currentStream) {
                currentStream.getTracks().forEach(track => track.stop());
            }

            // Define facing mode
            const facingMode = useFrontCamera ? 'user' : 'environment';

            // Request camera feed
            navigator.mediaDevices.getUserMedia({
                video: { facingMode: facingMode, width: { ideal: 1280 }, height: { ideal: 720 } }
            })
                .then((stream) => {
                    currentStream = stream;
                    cameraPreview.srcObject = stream;
                    cameraPreview.play();

                    // Initialize QuaggaJS
                    Quagga.init(
                        {
                            inputStream: {
                                type: 'LiveStream',
                                target: cameraPreview,
                                constraints: { facingMode: facingMode },
                            },
                            decoder: {
                                readers: ['code_128_reader', 'ean_reader'], // Add other readers as needed
                            },
                            locator: {
                                patchSize: 'medium', // Options: 'x-small', 'small', 'medium', 'large', 'x-large'
                                halfSample: false,  // Increase resolution
                            },
                        },
                        function (err) {
                            if (err) {
                                console.error('QuaggaJS initialization error:', err);
                                alert('Error initializing barcode scanner.');
                                return;
                            }
                            Quagga.start();
                            console.log('QuaggaJS started');
                        }
                    );

                    // On barcode detected
                    Quagga.onDetected(function (result) {
                        const barcode = result.codeResult.code;
                        const barcodeTextbox = document.getElementById('<%= txtBarcode.ClientID %>');
                        const searchButton = document.getElementById('<%= btnSearch.ClientID %>');

                        // Set barcode and trigger search
                        barcodeTextbox.value = barcode;
                        Quagga.stop();

                        if (currentStream) {
                            currentStream.getTracks().forEach(track => track.stop());
                        }

                        cameraContainer.classList.add('d-none');
                        searchButton.click();
                        console.log('Barcode detected:', barcode);
                    });
                })
                .catch((error) => {
                    console.error('Camera access error:', error);
                    alert('Unable to access the camera. Please check permissions or try again.');
                });
        }

        // Toggle between front and back cameras
        function toggleCamera() {
            const isUsingFrontCamera = currentStream.getVideoTracks()[0].getSettings().facingMode === 'user';
            openCamera(!isUsingFrontCamera);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server" class="container-fluid my-4">
        <!-- Scan Barcode Section -->
        <div id="DivScanForBilling" runat="server" class="col-sm-12">
            <div id="DivScanBarcode" runat="server" visible="false" class="col-sm-6 card mb-4 shadow-sm">
                <div class="card-header bg-primary text-white">
                    <h4>Scan Barcode</h4>
                </div>
                <div class="card-body">
                    <div class="d-flex mb-3">
                        <label for="txtBarcode" class="form-label w-25">Enter Barcode:</label>
                        <asp:TextBox ID="txtBarcode" runat="server" CssClass="form-control w-50" />
                        <button type="button" id="btnCamera" class="btn btn-outline-secondary w-25" onclick="openCamera()">
                            <i class="fa-solid fa-camera">Scan</i> 
                        </button>
                    </div>
                    <div class="d-flex justify-content-start gap-2">
                        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-success w-25" OnClick="btnSearch_Click" />
                        <asp:Button ID="btnAddProduct" runat="server" Text="New Product" CssClass="btn btn-secondary" OnClick="btnAddProduct_Click" />
                    </div>
                </div>
            </div>

            <!-- Product Details Section -->
            <div id="DivProductDetails" class="col-sm-6" runat="server" visible="false">
                <div class="card bg-info text-white mb-3">
                    <div class="card-header">
                        <h4>Product Details</h4>
                    </div>
                    <div class="card-body">
                        <asp:Repeater ID="dtScannedProduts" runat="server">
                            <HeaderTemplate>
                                <div class="table-responsive">
                                    <table class="table table-bordered table-hover">
                                        <thead class="thead-dark">
                                            <tr>
                                                <th>SR. No</th>
                                                <th>Product Name</th>
                                                <th>Description</th>
                                                <th>Quantity</th>
                                                <th>HSN Code</th>
                                                <th>Price</th>
                                                <th>Total Price</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <asp:Label ID="lblsrNo" runat="server" Text='<%# Container.ItemIndex + 1 %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblProductId" runat="server" Text='<%# Eval("ProductName") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblDescription" runat="server" Text='<%# Eval("ProductDesc") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblQuantity" runat="server" Text='<%# Eval("Qty") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblHSNCode" runat="server" Text='<%# Eval("HSNCode") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblPrice" runat="server" Text='<%# Eval("Price") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblTotalPrice" runat="server" Text='<%# Eval("TotalAmount") %>'></asp:Label>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                </tbody>
                        </table>
                    </div>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
        </div>


        <!-- Camera Preview -->
        <div id="cameraContainer" class="col-md-6 mt-3 d-none position-relative">
            <div class="camera-frame border rounded shadow-sm">
                <video id="cameraPreview" class="w-100 rounded"></video>
            </div>
            <!-- Overlay Instructions -->
            <div class="camera-overlay position-absolute top-50 start-50 translate-middle text-center text-white">
                <h5>Align the barcode in the frame</h5>
                <p>Scanning automatically...</p>
            </div>
        </div>

        <!-- Error Details Section -->
        <div id="DivError" runat="server" visible="false" class="col-md-6 card mb-4 shadow-sm">
            <div class="card-header bg-danger text-white">
                <h4>Error Details</h4>
            </div>
            <div class="card-body">
                <p>
                    <strong>Product Information : </strong>
                    <asp:Label ID="lblPNameError" runat="server" Text=""></asp:Label>
                </p>
                <p>
                    <strong>Add this Product from Scan next time...</strong>
                </p>
            </div>
        </div>

        <!-- Add Product Section -->
        <div id="DivAddProduct" runat="server" visible="false" class="col-md-6 card mb-4 shadow-sm">
            <div class="card-header bg-warning text-dark">
                <h4>Add Product</h4>
            </div>
            <div class="card-body">
                <div class="mb-3">
                    <label for="txtProductName" class="form-label">Product Name:</label>
                    <asp:TextBox ID="txtProductName" runat="server" CssClass="form-control" />
                </div>
                <div class="mb-3">
                    <label for="txtPDescription" class="form-label">Description:</label>
                    <asp:TextBox ID="txtPDescription" runat="server" CssClass="form-control" />
                </div>
                <div class="mb-3">
                    <label for="txtPPrice" class="form-label">Price:</label>
                    <asp:TextBox ID="txtPPrice" runat="server" CssClass="form-control" />
                </div>
                <div class="mb-3">
                    <label for="txtBarcodeNo" class="form-label">Barcode No.:</label>
                    <asp:TextBox ID="txtBarcodeNo" runat="server" CssClass="form-control" />
                </div>
                <div class="d-flex justify-content-start gap-2">
                    <button type="button" id="btnReturn" class="btn btn-outline-secondary w-25" onclick="ReturnToScanScreen()"><i class="fa fa-cross">Back</i></button>
                    <asp:Button ID="btnSaveProduct" runat="server" CssClass="btn btn-primary w-25" Text="Save" OnClick="btnSaveProduct_Click" />
                    <button type="button" id="btnCancel" class="btn btn-outline-danger w-25" onclick="ClearAll()"><i class="fa fa-cross">Cancel</i></button>
                </div>
            </div>
        </div>

        <!-- Additional Section -->
        <div id="DivReports" runat="server" visible="false" class="card mb-4 shadow-sm"></div>
    </form>
</body>

<script type="text/javascript">        
    function ReturnToScanScreen() {
        window.location.href = "ScanBarcode.aspx";
    }
    function ClearAll() {
        document.getElementById('<%= txtProductName.ClientID %>').value = '';
        document.getElementById('<%= txtPDescription.ClientID %>').value = '';
        document.getElementById('<%= txtPPrice.ClientID %>').value = '0.00';
        document.getElementById('<%= txtBarcodeNo.ClientID %>').value = '';
    }
</script>
</html>
