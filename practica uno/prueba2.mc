prueba2() {
    const int manzanas = 30;

    var int caidas;
    var int manzanaActual;

    var int compr1;

    while(manzanas){
        manzanaActual = manzanas;
        manzanas = manzanas-1;

        print("Manzana actual: ", manzanaActual, "\n");
        compr1 = (manzanaActual/2) * 2;



        if(manzanaActual - compr1){
            print("Manzana impar, no se cae\n");
        }
        else{
            caidas = caidas+1;
            print("Se cayó del arbol, manzanas caidas: ", caidas, "\n");
        }
    }
    
}