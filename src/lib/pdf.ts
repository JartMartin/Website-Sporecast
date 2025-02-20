import html2canvas from 'html2canvas';
import { jsPDF } from 'jspdf';

export async function generatePDF() {
  try {
    // Get the main content element
    const contentElement = document.querySelector('main');
    if (!contentElement) throw new Error('Could not find content element');

    // Get the selected tab content
    const activeTabContent = document.querySelector('[role="tabpanel"][data-state="active"]');
    if (!activeTabContent) throw new Error('Could not find active tab content');

    // Get the selected time horizon
    const activeTab = document.querySelector('[role="tab"][data-state="active"]');
    const timeHorizon = activeTab?.textContent || '12 Weeks';

    // Hide elements we don't want in the PDF
    const elementsToHide = contentElement.querySelectorAll('.loader, [role="dialog"], button:not([data-include-in-pdf="true"])');
    elementsToHide.forEach(el => (el as HTMLElement).style.display = 'none');

    // Configure html2canvas options
    const options = {
      scale: 2,
      useCORS: true,
      logging: false,
      backgroundColor: '#ffffff',
      windowWidth: contentElement.scrollWidth,
      windowHeight: contentElement.scrollHeight,
      onclone: (clonedDoc: Document) => {
        // Additional cleanup in the cloned document
        const clonedElement = clonedDoc.querySelector('main');
        if (clonedElement) {
          // Remove interactive elements
          clonedElement.querySelectorAll('button:not([data-include-in-pdf="true"]), .loader, [role="dialog"]').forEach(el => {
            el.remove();
          });
          
          // Remove sticky headers but keep content
          clonedElement.querySelectorAll('.sticky').forEach(el => {
            el.classList.remove('sticky');
            el.classList.remove('top-0');
            (el as HTMLElement).style.position = 'relative';
          });

          // Ensure all charts are visible
          clonedElement.querySelectorAll('.recharts-wrapper, .js-plotly-plot').forEach(el => {
            (el as HTMLElement).style.visibility = 'visible';
            (el as HTMLElement).style.display = 'block';
          });
        }
      }
    };

    // Create canvas
    const canvas = await html2canvas(contentElement, options);

    // Calculate dimensions
    const imgWidth = 210; // A4 width in mm
    const pageHeight = 297; // A4 height in mm
    const imgHeight = (canvas.height * imgWidth) / canvas.width;
    let heightLeft = imgHeight;
    let position = 0;

    // Create PDF
    const pdf = new jsPDF('p', 'mm', 'a4');
    let firstPage = true;

    // Add report header
    pdf.setFontSize(20);
    pdf.setTextColor(13, 148, 136); // teal-600
    pdf.text('Sporecast Market Report', 105, 20, { align: 'center' });
    
    // Add time horizon and date
    pdf.setFontSize(14);
    pdf.setTextColor(100, 100, 100);
    pdf.text(`${timeHorizon} Analysis`, 105, 30, { align: 'center' });
    pdf.setFontSize(12);
    pdf.text(new Date().toLocaleDateString(), 105, 40, { align: 'center' });

    // Add pages as needed
    while (heightLeft >= 0) {
      if (!firstPage) {
        pdf.addPage();
      }
      
      pdf.addImage(
        canvas.toDataURL('image/png'),
        'PNG',
        0,
        firstPage ? 50 : position, // Adjust first page for header
        imgWidth,
        imgHeight,
        '',
        'FAST'
      );
      
      heightLeft -= pageHeight;
      position -= pageHeight;
      firstPage = false;

      // Add page numbers
      pdf.setFontSize(10);
      pdf.setTextColor(150, 150, 150);
      pdf.text(
        `Page ${pdf.getCurrentPageInfo().pageNumber}`, 
        105, 
        290, 
        { align: 'center' }
      );
    }

    // Add metadata
    pdf.setProperties({
      title: `Sporecast Market Report - ${timeHorizon} Analysis`,
      subject: 'Commodity Market Analysis',
      author: 'Sporecast',
      keywords: 'commodities, market analysis, forecasting',
      creator: 'Sporecast'
    });

    // Add footer with disclaimer and timestamp
    pdf.setFontSize(8);
    pdf.setTextColor(150, 150, 150);
    const disclaimer = 'CONFIDENTIAL: This report contains proprietary market analysis and forecasting data. Not for distribution.';
    pdf.text(disclaimer, 105, 285, { align: 'center' });
    
    const timestamp = `Generated on ${new Date().toLocaleString()}`;
    pdf.text(timestamp, 105, 282, { align: 'center' });

    // Download the PDF
    pdf.save(`sporecast-market-report-${timeHorizon.toLowerCase().replace(/\s+/g, '-')}-${new Date().toISOString().split('T')[0]}.pdf`);

    // Restore hidden elements
    elementsToHide.forEach(el => (el as HTMLElement).style.display = '');

    return true;
  } catch (error) {
    console.error('Error generating PDF:', error);
    // Restore hidden elements in case of error
    const elementsToRestore = document.querySelectorAll('.loader, [role="dialog"], button:not([data-include-in-pdf="true"])');
    elementsToRestore.forEach(el => (el as HTMLElement).style.display = '');
    return false;
  }
}