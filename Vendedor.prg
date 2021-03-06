#include "FiveWin.Ch"
#include "Factu.ch"
#include "Report.ch"

//--------------------------------------------------------------------------//

/*
Base de datos de Vendedores
*/

#define _CCODVEN                   1      //   C      3     0
#define _CNOMVEN                   2      //   C     30     0
#define _CNIFVEN                   3      //   C     15     0
#define _CDOMVEN                   4      //   C     35     0
#define _CPOBVEN                   5      //   C     25     0
#define _CPRVVEN                   6      //   C     20     0
#define _CCPSVEN                   7      //   C      7     0
#define _CTELVEN                   8      //   C     12     0
#define _CFAXVEN                   9      //   C     12     0

static oWndBrw
static dbfVendedor
static bEdit := { |aTemp, aoGet, dbfVendedor, oBrw, bWhen, bValid, nMode | EdtRec( aTemp, aoGet, dbfVendedor, oBrw, bWhen, bValid, nMode ) }
static aBase := { { "CCODVEN",   "C",   3,  0, "" },;
						{ "CNOMVEN",   "C",  30,  0, "" },;
						{ "CNIFVEN",   "C",  15,  0, "" },;
						{ "CDOMVEN",   "C",  35,  0, "" },;
						{ "CPOBVEN",   "C",  25,  0, "" },;
						{ "CPRVVEN",   "C",  20,  0, "" },;
						{ "CCPSVEN",   "C",   7,  0, "" },;
						{ "CTELVEN",   "C",  12,  0, "" },;
						{ "CFAXVEN",   "C",  12,  0, "" } }

//----------------------------------------------------------------------------//

FUNCTION Vendedor( oWnd )

	IF oWndBrw == NIL

	Reindex()

   USE ( cPatEmp() + "VENDEDOR.DBF" ) NEW VIA ( cDriver() ) SHARED ALIAS ( cCheckArea( "VENDEDOR", @dbfVendedor ) )
   SET ADSINDEX TO ( cPatEmp() + "VENDEDOR.CDX" ) ADDITIVE

   DEFINE SHELL oWndBrw FROM 2, 10 TO 18, 70;
		TITLE 	"Vendedor" ;
		FIELDS 	(dbfVendedor)->CCODVEN,;
					(dbfVendedor)->CNOMVEN,;
					(dbfVendedor)->CNIFVEN,;
					(dbfVendedor)->CDOMVEN,;
					(dbfVendedor)->CPOBVEN,;
					(dbfVendedor)->CPRVVEN,;
					(dbfVendedor)->CCPSVEN,;
					(dbfVendedor)->CTELVEN,;
					(dbfVendedor)->CFAXVEN;
		HEAD 		"Codg.",;
					"Nombre",;
					"N.I.F.",;
					"Domicilio",;
					"Poblaci�n",;
					"Provincia",;
					"Cod. Postal",;
					"Telefono",;
					"Fax";
      PROMPT   "Codigo",;
					"Nombre";
		ALIAS		( dbfVendedor ) ;
		APPEND	( WinAppRec( oWndBrw:oBrw, bEdit, dbfVendedor, , {|oGet| NotValid( oGet, dbfVendedor, .T., "0" ) } ) );
		DUPLICAT ( WinDupRec( oWndBrw:oBrw, bEdit, dbfVendedor, , {|oGet| NotValid(oGet, dbfVendedor, .T., "0") } ) );
		EDIT 		( WinEdtRec( oWndBrw:oBrw, bEdit, dbfVendedor ) ) ;
		DELETE   ( DBDelRec(  oWndBrw:oBrw, dbfVendedor ) ) ;
		OF 		oWnd

		DEFINE BTNSHELL RESOURCE "NEW" OF oWndBrw ;
			NOBORDER ;
			ACTION 	( oWndBrw:RecAdd() );
			ON DROP	( oWndBrw:RecDup() );
			TOOLTIP 	"(A)�adir";
			HOTKEY 	"A"

		DEFINE BTNSHELL RESOURCE "DUP" OF oWndBrw ;
			NOBORDER ;
			ACTION 	( oWndBrw:RecDup() );
			TOOLTIP 	"(D)uplicar";
			HOTKEY 	"D"

		DEFINE BTNSHELL RESOURCE "EDIT" OF oWndBrw ;
			NOBORDER ;
			ACTION  	( oWndBrw:RecEdit() );
			TOOLTIP 	"(M)odifica";
			HOTKEY 	"M"

		DEFINE BTNSHELL RESOURCE "ZOOM" OF oWndBrw ;
			NOBORDER ;
			ACTION  	( WinZooRec( oWndBrw:oBrw, bEdit, dbfVendedor ) );
			TOOLTIP 	"(Z)oom";
			HOTKEY 	"Z"

		DEFINE BTNSHELL RESOURCE "DEL" OF oWndBrw ;
			NOBORDER ;
			ACTION 	( oWndBrw:RecDel() );
			TOOLTIP 	"(E)liminar";
			HOTKEY 	"E"

		DEFINE BTNSHELL RESOURCE "BUS" OF oWndBrw ;
			NOBORDER ;
			ACTION 	( oWndBrw:Search() ) ;
			TOOLTIP 	"(B)uscar";
			HOTKEY 	"B"

		DEFINE BTNSHELL RESOURCE "IMP" OF oWndBrw ;
			NOBORDER ;
			ACTION ( MsgInfo( "GenReport( dbfVendedor )" ) ) ;
			TOOLTIP "(L)istado" ;
			HOTKEY 	"L"

      DEFINE BTNSHELL RESOURCE "END" GROUP OF oWndBrw ;
			NOBORDER ;
			ACTION ( oWndBrw:End() ) ;
			TOOLTIP "(S)alir" ;
			HOTKEY 	"S"

		ACTIVATE WINDOW oWndBrw ;
			VALID ( oWndBrw:oBrw:lCloseArea(), oWndBrw := NIL, .t. )

	ELSE

		oWndBrw:SetFocus()

	END IF

RETURN NIL

//--------------------------------------------------------------------------//

STATIC FUNCTION EdtRec( aTemp, aoGet, dbfTarPreT, oBrw, bWhen, bValid, nMode )

	local oDlg

	DEFINE DIALOG oDlg RESOURCE "ALMACEN" TITLE LblTitle( nMode ) + "Vendedor"

		REDEFINE GET oGet VAR aTemp[ _CCODVEN ];
			ID 	100 ;
			WHEN  ( EVAL( bWhen, oGet ) ) ;
			VALID ( EVAL( bValid, oGet ) ) ;
			COLOR CLR_GET ;
			OF 	oDlg

		REDEFINE GET aoGet[ _CNOMVEN ] VAR aTemp[ _CNOMVEN ];
			ID 	110 ;
			WHEN  ( nMode != ZOOM_MODE ) ;
			COLOR CLR_GET ;
			OF 	oDlg

		REDEFINE GET aoGet[ _CNIFVEN ] VAR aTemp[ _CNIFVEN ];
			ID 	120 ;
			WHEN  ( nMode != ZOOM_MODE ) ;
			COLOR CLR_GET ;
			OF 	oDlg

		REDEFINE GET aoGet[ _CDOMVEN ] VAR aTemp[ _CDOMVEN ];
			ID 	130 ;
			WHEN  ( nMode != ZOOM_MODE ) ;
			COLOR CLR_GET ;
			OF 	oDlg

		REDEFINE GET aoGet[ _CCPSVEN ] VAR aTemp[ _CCPSVEN ];
			ID 	140 ;
			WHEN  ( nMode != ZOOM_MODE ) ;
			COLOR CLR_GET ;
			OF 	oDlg

		REDEFINE GET aoGet[ _CPOBVEN ] VAR aTemp[ _CPOBVEN ];
			ID 	150 ;
			WHEN  ( nMode != ZOOM_MODE ) ;
			COLOR CLR_GET ;
			OF 	oDlg

		REDEFINE GET aoGet[ _CPRVVEN ] VAR aTemp[ _CPRVVEN ];
			ID 	160 ;
			WHEN  ( nMode != ZOOM_MODE ) ;
			COLOR CLR_GET ;
			OF 	oDlg

		REDEFINE GET aoGet[ _CTELVEN ] VAR aTemp[ _CTELVEN ];
			ID 	170 ;
			WHEN  ( nMode != ZOOM_MODE ) ;
			PICTURE "@R (###)#######" ;
			COLOR CLR_GET ;
			OF 	oDlg

		REDEFINE GET aoGet[ _CFAXVEN ] VAR aTemp[ _CFAXVEN ];
			ID 	180 ;
			WHEN  ( nMode != ZOOM_MODE ) ;
			PICTURE "@R (###)#######" ;
			COLOR CLR_GET ;
			OF 	oDlg

		REDEFINE BUTTON ;
         ID    IDOK ;
			OF 	oDlg ;
			WHEN 	( nMode != ZOOM_MODE ) ;
         ACTION ( WinGather( aTemp, aoGet, dbfVendedor, oBrw, nMode ), oDlg:end( IDOK ) )

		REDEFINE BUTTON ;
         ID IDCANCEL ;
			OF oDlg ;
			ACTION ( oDlg:end() )

	ACTIVATE DIALOG oDlg	CENTER

RETURN ( oDlg:nResult == IDOK )

//---------------------------------------------------------------------------//

/*
Devuelve el nombre de un proveedor
cCodigo		- Codigo de Barra del Articulo a Buscar
dbfVendedor - Alias de la base de datos donde buscamos
*/

FUNCTION cNomVen( cCodigo, dbfVendedor )

	local cNombre 	:= ""
	local nRecNo   := ( dbfVendedor )->( RecNo() )
	local nOrdAnt	:= ( dbfVendedor )->( OrdSetFocus( 1 ) )

	IF ( dbfVendedor )->( dbSeek( cCodigo ) )
		cNombre 		:= ( dbfVendedor )->CNOMVEN
	END IF

	( dbfVendedor )->( OrdSetFocus( nOrdAnt ) )
	( dbfVendedor )->( dbGoTo( nRecNo ) )

RETURN cNombre

//--------------------------------------------------------------------------//

FUNCTION rxVendedor( cPath, oMeter )

RETURN Reindex( oMeter, cPath )

//----------------------------------------------------------------------------//

STATIC FUNCTION Reindex( oMeter, cPath )

   DEFAULT cPath := cPatEmp()

   IF !File( cPatEmp() + "VENDEDOR.DBF" )
		CreateFiles()
	END IF

   fErase( cPath + "VENDEDOR.CDX" )

   USE ( cPatEmp() + "VENDEDOR.DBF" ) NEW VIA ( cDriver() )ALIAS ( cCheckArea( "VENDEDOR", @dbfVendedor ) )
   if !( dbfVendedor )->( neterr() )
      ( dbfVendedor )->( __dbPack() )

      ( dbfVendedor )->( ordCondSet("!Deleted()", {||!Deleted()}  ) )
      ( dbfVendedor )->( ordCreate( cPath + "VENDEDOR.CDX", "CCODVEN", "CCODVEN", {|| CCODVEN }, ) )

      ( dbfVendedor )->( dbCloseArea() )
      dbfVendedor := nil
   else
      msgStop( "Imposible abrir en modo exclusivo la tabla de vendedores" )
   end if

RETURN NIL

//--------------------------------------------------------------------------//

FUNCTION mkVendedor( cPath, oMeter )

RETURN CreateFiles( cPath, oMeter )

//----------------------------------------------------------------------------//

STATIC FUNCTION CreateFiles( cPath, oMeter )

   DEFAULT cPath := cPatEmp()

   dbCreate( cPath + "VENDEDOR.DBF", aBase, cDriver() )

	Reindex( oMeter, cPath )

RETURN NIL

//----------------% )  {{{{Seleccione la propiedad 	HELPENTRY {d{{{{{d{{{{{< 