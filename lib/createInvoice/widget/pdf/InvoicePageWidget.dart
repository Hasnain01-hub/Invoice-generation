import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class InvoicePage extends Page {
  final PdfImage headerImage;

  InvoicePage({
    PdfImage this.headerImage,
    BuildCallback build,
    EdgeInsets margin,
  }) : super(
       build: build,
    margin: margin,
    pageFormat: PdfPageFormat.a3,
    orientation: PageOrientation.portrait,
  );

  @override
  void paint(Widget child, Context context) {
    if(headerImage != null){
      final imgProportions = headerImage.width / headerImage.height;
      context.canvas.drawImage(
          headerImage,
          0,
          PdfPageFormat.a3.height - (headerImage.height / imgProportions),
          PdfPageFormat.a3.width
      );
    }
    super.paint(child, context);
  }

}