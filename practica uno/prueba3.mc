prueba() {



    var int num;
    var int num2;

    print("Introduce dos números: \n");

    read(num, num2);

    
    if(num){

        if(num2-num){
            if(num2/num){
                print("El número ",num," es menor que ",num2);
            }  
            else{
                print("El número ",num," es mayor que ",num2);
            }
        }
        else{
            print("Los numeros son iguales");
        }

    }
    else if(num2){

        if(num2-num){
            if(num/num2){
            print("El número ",num," es mayor que ",num2);
            }  
            else{
                print("El número ",num," es menor que ",num2);
            }
        }
        else{
            print("Los numeros son iguales");
        }
        
    }
    else{
        print("Los numeros son iguales");
    }
    

}
