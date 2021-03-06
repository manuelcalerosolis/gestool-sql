#include "FiveWin.Ch"
#include "Font.ch"
#include "Factu.ch" 
#include "MesDbf.ch"

//---------------------------------------------------------------------------//

CLASS TRenPep FROM TPrvAlm

   DATA  lExcMov     AS LOGIC    INIT .f.
   DATA  lCosAct     AS LOGIC    INIT .f.
   DATA  oPedPrvT    AS OBJECT
   DATA  oPedPrvL    AS OBJECT
   DATA  oEstado     AS OBJECT
   DATA  oArt        AS OBJECT
    

   METHOD Create()

   METHOD OpenFiles()

   METHOD CloseFiles()

   METHod lResource( cFld )

   METHOD lGenerate()


END CLASS

//---------------------------------------------------------------------------//

METHOD Create()

   ::RentCreateFields()

   ::AddTmpIndex( "CCODALM", "CCODALM + CCODART" )
   ::AddGroup( {|| ::oDbf:cCodAlm },                     {|| "Almac�n  : " + Rtrim( ::oDbf:cCodAlm ) + "-" + Rtrim( oRetFld( ::oDbf:cCodAlm, ::oDbfAlm ) ) }, {||"Total almac�n..."} )
   ::AddGroup( {|| ::oDbf:cCodAlm + ::oDbf:cCodArt },    {|| "Art�culo : " + Rtrim( ::oDbf:cCodArt ) + "-" + Rtrim( oRetFld( ::oDbf:cCodArt, ::oArt ) ) }, {||""} )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD OpenFiles() CLASS TRenPep

   /*
   Ficheros necesarios
   */

   DATABASE NEW ::oArt     PATH ( cPatEmp() ) FILE "ARTICULO.DBF" VIA ( cDriver() ) SHARED INDEX "ARTICULO.CDX"

    

   DATABASE NEW ::oPedPrvT PATH ( cPatEmp() ) FILE "PEDPROVT.DBF" VIA ( cDriver() ) SHARED INDEX "PEDPROVT.CDX"
   ::oPedPrvT:OrdSetFocus( "dFecPed" )

   DATABASE NEW ::oPedPrvL PATH ( cPatEmp() ) FILE "PEDPROVL.DBF" VIA ( cDriver() ) SHARED INDEX "PEDPROVL.CDX"

   DATABASE NEW ::oDbfPrv  PATH ( cPatEmp() ) FILE "PROVEE.DBF"  VIA ( cDriver() ) SHARED INDEX "PROVEE.CDX"

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD CloseFiles() CLASS TRenPep

   ::oArt:End()
   ::oPedPrvT:End()
   ::oPedPrvL:End()
   ::oDbfPrv:End()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHod lResource( cFld ) CLASS TRenPep

   if !::StdResource( "INF_GEN10E" )
      return .f.
   end if

   /*
   Monta los almacenes de manera automatica
   */

   ::oDefAlmInf( 110, 120, 130, 140 )

   /*
   Monta los articulos de manera automatica
   */

   ::lDefArtInf( 70, 80, 90, 100 )

   ::oDefExcInf( 204 )

   ::oDefResInf()

   REDEFINE CHECKBOX ::lExcMov ;
      ID       ( 203 );
      OF       ::oFld:aDialogs[1]

   REDEFINE CHECKBOX ::lCosAct ;
      ID       ( 205 );
      OF       ::oFld:aDialogs[1]


RETURN .t.

//---------------------------------------------------------------------------//
/*
Esta funcion crea la base de datos para generar posteriormente el informe
*/

METHOD lGenerate() CLASS TRenPep

   local nTotUni
   local nTotImpUni  := 0
   local nTotCosUni  := 0
   local lExcCero    := .f.

   ::aHeader   := {  {|| "Fecha  : " + Dtoc( Date() ) },;
                     {|| "Periodo: " + Dtoc( ::dIniInf ) + " > " + Dtoc( ::dFinInf ) },;
                     {|| "Almacenes: " + AllTrim( ::cAlmOrg )      + " > " + AllTrim (::cAlmDes ) },;
                     {|| "Art�culos: " + AllTrim( ::cArtOrg )      + " > " + AllTrim (::cArtDes ) } }

   ::oDlg:Disable()

   ::oDbf:Zap()

   /*
   Damos valor al meter
   */

   ::oMtrInf:SetTotal( ::oPedPrvT:Lastrec() )

   ::oPedPrvT:GoTop()

   ::oPedPrvT:Seek ( ::dIniInf , .t. )

   while ::oPedPrvT:dFecPed <= ::dFinInf .and. !::oPedPrvT:Eof()

      if lChkSer( ::oPedPrvT:cSerPed, ::aSer )

         if ::oPedPrvL:Seek( ::oPedPrvT:cSerPed + Str( ::oPedPrvT:nNumPed ) + ::oPedPrvT:cSufPed )

            while ::oPedPrvL:cSerPed + Str( ::oPedPrvL:nNumPed ) + ::oPedPrvL:cSufPed == ::oPedPrvT:cSerPed + Str( ::oPedPrvT:nNumPed ) + ::oPedPrvT:cSufPed

               if ::oPedPrvL:cAlmLin >= ::cAlmOrg                                                                        .AND.;
                  ::oPedPrvL:cAlmLin <= ::cAlmDes                                                                        .AND.;
                  ::oPedPrvL:cRef >= ::cArtOrg                                                                           .AND.;
                  ::oPedPrvL:cRef <= ::cArtDes                                                                           .AND.;
                  !( ::oPedPrvL:lKitArt )                                                                                .AND.;
                  !( ::lExcCero .AND. ( nTotNPedPrv( ::oPedPrvL:cAlias ) == 0 ) )                                        .AND.;
                  !( ::lExcMov  .AND. ( nImpLPedPrv( ::oPedPrvT:cAlias, ::oPedPrvL:cAlias, ::nDecOut, ::nDerOut ) == 0  ) )

                  nTotUni              := nTotNPedPrv( ::oPedPrvL:cAlias )
                  nTotImpUni           := nImpLPedPrv( ::oPedPrvT:cAlias, ::oPedPrvL:cAlias, ::nDecOut, ::nDerOut )

                  if ::lCosAct .or. ::oPedPrvL:nPreDiv == 0
                     nTotCosUni        := nRetPreCosto( ::oArt:cAlias, ::oPedPrvL:cRef ) * nTotUni
                  else
                     nTotCosUni        := ::oPedPrvL:nPreDiv * nTotUni
                  end if

                  ::oDbf:Append()

                  ::oDbf:cCodArt    := ::oPedPrvL:cRef
                  ::oDbf:cCodAlm    := ::oPedPrvL:cAlmLin
                  ::oDbf:cNomArt :=  RetArticulo( ::oPedPrvL:cRef, ::oArt )

                  ::AddProveedor( ::oPedPrvT:cCodPrv )

                  ::oDbf:nTotCaj    := ::oPedPrvL:nCanEnt
                  ::oDbf:nTotUni    := nTotUni
                  ::oDbf:nTotImp    := nTotImpUni
                  ::oDbf:nTotCos    := nTotCosUni
                  ::oDbf:nMargen    := nTotImpUni - nTotCosUni

                  if nTotUni != 0 .and. nTotCosUni != 0
                     ::oDbf:nRentab := ( ( nTotImpUni / nTotCosUni ) - 1 ) * 100
                     ::oDbf:nPreMed := nTotImpUni / nTotUni
                     ::oDbf:nCosMed := nTotCosUni / nTotUni
                  else
                     ::oDbf:nRentab := 0
                     ::oDbf:nPreMed := 0
                     ::oDbf:nCosMed := 0
                  end if

                  ::oDbf:cNumDoc    := ::oPedPrvL:cSerPed + "/" + Alltrim( Str( ::oPedPrvL:nNumPed ) ) + "/" + ::oPedPrvL:cSufPed

                  ::oDbf:Save()

               end if

               ::oPedPrvL:Skip()

            end while

         end if

      end if

      ::oMtrInf:AutoInc( ::oPedPrvT:OrdKeyNo() )

      ::oPedPrvT:Skip()

   end while

   ::oMtrInf:AutoInc( ::oPedPrvT:Lastrec() )

  ::oDlg:Enable()

RETURN ( ::oDbf:LastRec() > 0 )

//---------------------------------------------------------------------------//