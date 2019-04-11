#include <WinTen.h>
#include <ClipApi.h>
#include <Windows.h>

#define DT_EDITCONTROL       0x00002000
#define DT_MODIFYSTRING      0x00010000
#define DT_WORD_ELLIPSIS     0x00040000
#define DT_END_ELLIPSIS      0x00008000
#define DT_SINGLELINE        0x0020

#define TRANSPARENT          1
#define OPAQUE               2

#define BORDER_SPACE         2
#define MENU_SPACE           18

void DrawMasked( HDC hDC, HBITMAP hBmp, WORD wRow, WORD wCol );
void DrawBitmap( HDC hDC, HBITMAP hBmp, WORD wCol, WORD wRow, WORD wWidth, WORD wHeight, DWORD dwRaster );
void WndDrawBox( HDC hDC, RECT * rct, HPEN hPUpLeft, HPEN hPBotRit );

//---------------------------------------------------------------------------//

void nCuentame( LONG Num )
{
	char szBuffer[ 80 ];
	wsprintf( szBuffer, "%ld", Num );

    MessageBox( 0, szBuffer, "Aviso", MB_ICONINFORMATION | MB_SYSTEMMODAL );
}

//---------------------------------------------------------------------------//

CLIPPER PAINTWB( PARAMS )   // hWnd, hDC, bIsOver, strText, bIsMenu, hPalBmp1, hFont, hFontOver
{                           // nClrText, nClrTextOver, nTop, nLeft, nHeight, nWidth, nPad
                            // hPalBmp2, bIsOverMenu
    int hOldDC;

    HFONT hOldFont;
    BITMAP bm;
    RECT rct;
    RECT brdrct;
    HBRUSH hBrush;
    HBRUSH hBrushOld;
    HPEN hOldPen;
    HPEN hPen;
    BOOL bDestroyDC         = FALSE;

    HWND hWnd               = ( HWND ) _parnl( 1 );
    HDC hDC                 = _parni( 2 );

    BOOL bIsOver            = _parl( 3 );
    LPSTR strText           = _parc( 4 );
    WORD wLen               = _parclen( 4 );
    BOOL bIsMenu            = _parl( 5 );
    LONG hPalBmp1           = _parnl( 6 );
    HFONT hFont             = _parni( 7 );
    HFONT hFontOver         = _parni( 8 );
    COLORREF clrText        = _parnl( 9 );
    COLORREF clrTextOver    = _parnl( 10 );
    WORD wPad               = _parnl( 15 );
    LONG hPalBmp2           = _parnl( 16 );
    BOOL bIsOverMenu        = _parl( 21 );
    BOOL bBorder            = _parl( 22 );
    COLORREF clrBrdTop      = _parnl( 23 );
    COLORREF clrBrdBot      = _parnl( 24 );
    COLORREF clrBrdTopOver  = _parnl( 25 );
    COLORREF clrBrdBotOver  = _parnl( 26 );
    BOOL bPressed           = _parl( 27 );
    BOOL bWebBar            = _parl( 28 );
    BOOL bOpnGrp            = _parl( 29 );
    BOOL bSelect            = _parl( 30 );
    BOOL bTransparent       = _parl( 31 );
    BOOL bSingleLine        = _parl( 32 );

    POINT pt[3];
    int iBitmapPosition;

    char cadena[256];

    if ( bPressed )
    {
        bIsOver             = bPressed;
    }

    if( ! hDC )
    {
        bDestroyDC          = TRUE;
        hDC                 = GetDC( hWnd );
    }

    hOldDC                  = SaveDC( hDC );

    rct.top                 = BORDER_SPACE;
    rct.left                = BORDER_SPACE;
    if ( LOWORD( hPalBmp1 ) )
        {
        GetObject( ( HGDIOBJ ) LOWORD( hPalBmp1 ), sizeof( BITMAP ), ( LPSTR ) &bm );
        rct.left            = bm.bmWidth > 0 ? BORDER_SPACE + bm.bmWidth + BORDER_SPACE : BORDER_SPACE ;
        }
    rct.bottom              = _parnl( 13 ) - BORDER_SPACE;
    rct.right               = _parnl( 14 ) - ( bWebBar ? MENU_SPACE : 0 );

    SetBkMode( hDC, TRANSPARENT );

    hOldFont                = SelectObject( hDC, bIsOver && !bIsOverMenu ? hFontOver : hFont );
    SetTextColor( hDC, bIsOver && !bIsOverMenu ? clrTextOver : clrText );

    if ( LOWORD( hPalBmp1 ) )
    {
        switch ( wPad )
        {
            case 1 :
                if ( bTransparent )
                {
                    DrawMasked( hDC, bIsOver ? hPalBmp2 : hPalBmp1, ( ( rct.bottom - rct.top ) - bm.bmHeight ) / 2 , BORDER_SPACE );
                }
                else
                {
                    DrawBitmap( hDC, bIsOver ? hPalBmp2 : hPalBmp1, ( ( rct.bottom - rct.top ) - bm.bmHeight ) / 2 , BORDER_SPACE, bm.bmWidth, bm.bmHeight, 0 );
                }
                break;

            case 2 :
                iBitmapPosition = ( rct.right - rct.left ) - ( bm.bmWidth / 2 );
                if ( iBitmapPosition < 0 )
                {
                    iBitmapPosition = 0 ;
                }

                if ( bTransparent )
                {
                    DrawMasked( hDC, bIsOver ? hPalBmp2 : hPalBmp1, ( ( rct.bottom - rct.top ) - bm.bmHeight ) / 2 , iBitmapPosition );
                }
                else
                {
                    DrawBitmap( hDC, bIsOver ? hPalBmp2 : hPalBmp1, ( ( rct.bottom - rct.top ) - bm.bmHeight ) / 2 , iBitmapPosition, bm.bmWidth, bm.bmHeight, 0 );
                }
                break;
        }
    }

    switch ( wPad )
    {
        case 1 :
            DrawText( hDC, strText, wLen, &rct, ( DT_EDITCONTROL | ( bSingleLine ? DT_SINGLELINE : DT_WORDBREAK ) | DT_END_ELLIPSIS | DT_VCENTER | DT_LEFT ) );
            break;
        case 2 :
            DrawText( hDC, strText, wLen, &rct, ( DT_EDITCONTROL | ( bSingleLine ? DT_SINGLELINE : DT_WORDBREAK ) | DT_END_ELLIPSIS | DT_VCENTER | DT_CENTER ) );
            break;
        case 3 :
            DrawText( hDC, strText, wLen, &rct, ( DT_EDITCONTROL | ( bSingleLine ? DT_SINGLELINE : DT_WORDBREAK ) | DT_END_ELLIPSIS | DT_VCENTER | DT_RIGHT ) );
            break;
    }

    if ( bIsMenu )
    {
        hPen            = CreatePen( PS_SOLID, 1,  bIsOverMenu ? clrTextOver : clrText );
        hOldPen         = SelectObject( hDC, hPen );
        hBrush          = CreateSolidBrush(  bIsOverMenu ? clrTextOver : clrText );
        hBrushOld       = SelectObject( hDC, hBrush );

        if( bOpnGrp )
        {
            MoveTo( hDC, rct.right +  4,  9 );
            LineTo( hDC, rct.right + 10,  9 );
            LineTo( hDC, rct.right +  7,  6 );
            LineTo( hDC, rct.right +  4,  9 );

            ExtFloodFill( hDC, rct.right + 7, 8, bIsOverMenu ? clrTextOver : clrText, 0 );
        }
        else
        {
            MoveTo( hDC, rct.right +  4,  6 );
            LineTo( hDC, rct.right + 10,  6 );
            LineTo( hDC, rct.right +  7,  9 );
            LineTo( hDC, rct.right +  4,  6 );

            ExtFloodFill( hDC, rct.right + 6, 7, bIsOverMenu ? clrTextOver : clrText, 0 );
        }
        SelectObject( hDC, hOldPen );
        DeleteObject( hPen );
        SelectObject( hDC, hBrushOld );
        DeleteObject( hBrush );
    }

    SetBkMode( hDC, OPAQUE );
    SelectObject( hDC, hOldFont );

    if ( bBorder )
    {
        GetClientRect( hWnd, &brdrct );

        hPen            = CreatePen( PS_SOLID, 1, bIsOver ? clrBrdTopOver : clrBrdTop );
        hOldPen         = SelectObject( hDC, hPen );
        MoveTo( hDC, 0, brdrct.bottom );
        LineTo( hDC, 0, 0 );
        LineTo( hDC, brdrct.right, 0 );
        SelectObject( hDC, hOldPen );
        DeleteObject( hPen );

        hPen            = CreatePen( PS_SOLID, 1, bIsOver ? clrBrdBotOver : clrBrdBot );
        hOldPen         = SelectObject( hDC, hPen );
        MoveTo( hDC, 0, brdrct.bottom - 1 );
        LineTo( hDC, brdrct.right - 1, brdrct.bottom - 1 );
        LineTo( hDC, brdrct.right - 1, 0 );
        SelectObject( hDC, hOldPen );
        DeleteObject( hPen );
    }

    if( bSelect )
    {
        GetClientRect( hWnd, &brdrct );

        hPen            = CreatePen( PS_SOLID, 1, clrText );
        hOldPen         = SelectObject( hDC, hPen );
        MoveTo( hDC, brdrct.right - 1, 0 );
        LineTo( hDC, brdrct.right - 1, 1 );
        LineTo( hDC, 0, 1 );
        LineTo( hDC, 0, brdrct.bottom - 4 );
        LineTo( hDC, brdrct.right - 1, brdrct.bottom - 4 );
        LineTo( hDC, brdrct.right - 1, brdrct.bottom - 2 );
        SelectObject( hDC, hOldPen );
        DeleteObject( hPen );
    }

    RestoreDC( hDC, hOldDC );

    if( bDestroyDC )
        ReleaseDC( hWnd, hDC );

}
//---------------------------------------------------------------------------//

CLIPPER CLEANWB( PARAMS )   // hWnd, hDC, nWidth, nHeight, nLeft, nTop, hPalBmpBk, nColor
{

    HDC hDCMemX;
    HBITMAP hBmpOld;
    HBRUSH hBrush;
    RECT rct;
    BOOL bDestroyDC         = FALSE;

    HWND hWnd               = ( HWND ) _parnl( 1 );
    HDC hDC                 = _parni( 2 );
    LONG hPalBmpBk          = _parnl( 7 );
    COLORREF nColor         = _parnl( 8 );

    if( ! hDC )
    {
        bDestroyDC          = TRUE;
        hDC                 = GetDC( hWnd );
    }

    if( hPalBmpBk != 0 )
    {
        hDCMemX             = CreateCompatibleDC( hDC );
        hBmpOld             = SelectObject( hDCMemX, hPalBmpBk );

        BitBlt( hDC, 0, 0, _parnl( 3 ), _parnl( 4 ), hDCMemX, _parnl( 5 ), _parnl( 6 ), SRCCOPY );

        SelectObject( hDCMemX, hBmpOld );
        DeleteDC( hDCMemX );
    }
    else
    {
        hBrush              = CreateSolidBrush( nColor ) ;
        GetClientRect( hWnd, &rct );
        FillRect( hDC, &rct, hBrush ) ;
        DeleteObject( hBrush );
    }

    if( bDestroyDC )
        ReleaseDC( hWnd, hDC );

}

//---------------------------------------------------------------------------//

CLIPPER StretchBLt()
{
   _retl(StretchBlt( _parni(1),_parni(2),_parni(3),_parni(4),_parni(5),
                     _parni(6),_parni(7),_parni(8),_parni(9),_parni(10),
                     _parnl(11)));

}

//---------------------------------------------------------------------------//

CLIPPER CompatDC() // ( hDC )
{
   _retni( CreateCompatibleDC( _parni( 1 ) ) );

}

//---------------------------------------------------------------------------//

CLIPPER CompatBmp() // ( hDC, nWidth, nHeight )
{
   _retni( CreateCompatibleBitmap( _parni( 1 ), _parni( 2 ), _parni( 3 ) ) );

}

//---------------------------------------------------------------------------//

/*
CLIPPER WRITEFILE( PARAMS )
{
   _retni( WriteFile( _parni( 1 ), _parc( 2 ), _parclen( 2 ) ) );
}
*/
//---------------------------------------------------------------------------//


    /*
    char cadena[256];

    GetWindowRect( hWnd, &rct );
    wsprintf( cadena, "Top=%d", bIsOverMenu );
    MessageBox( 0, cadena, "Parametros", MB_OK );
    wsprintf( cadena, "Top=%d Left=%d Bottom=%d Right=%d", rct.top, rct.left, rct.bottom, rct.right );
    MessageBox( 0, cadena, strText, MB_OK );
    */

    /*
    GetClientRect( hWnd, &rct );
    wsprintf( cadena, "Pad=%d", wPad );
    MessageBox( 0, cadena, strText, MB_OK );
    */

    /*
        hPen            = CreatePen( PS_SOLID, 1,  bIsOverMenu ? clrTextOver : clrText );
        hOldPen         = SelectObject( hDC, hPen );
        MoveTo( hDC, rct.right + 4,  2 );
        LineTo( hDC, rct.right + 8,  6 );
        LineTo( hDC, rct.right + 4, 10 );
        LineTo( hDC, rct.right + 4,  2 );
        SelectObject( hDC, hOldPen );
        DeleteObject( hPen );

        hBrush          = CreateSolidBrush(  bIsOverMenu ? clrTextOver : clrText );
        hBrushOld       = SelectObject( hDC, hBrush );
        ExtFloodFill( hDC, rct.right + 6, 6, bIsOverMenu ? clrTextOver : clrText, 0 );
        SelectObject( hDC, hBrushOld );
        DeleteObject( hBrush );
    */