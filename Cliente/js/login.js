var user = {USUARIOSID:'1', NOMBREUSUARIO:'', CONTRASENIA:'', ROL:'1'}
const urlBase = 'http://localhost:8080/api';


document.getElementById("button-submit").addEventListener("click", async function(event){
    event.preventDefault()
    

    user.NOMBREUSUARIO = document.getElementById('login').value;
    user.CONTRASENIA = document.getElementById('password').value;
    

    let response = await DoLogin(user);

    console.log(response)


    
});


const DoLogin = async (user) => {
    try {
        const req = new Request(urlBase+'/usuarios/login', {
            method: 'POST', 
            mode: 'no-cors',
            headers: {'Content-Type': 'application/json', 'Accept':'*/*'},
            body: JSON.stringify(user) 
          });
    
        const res = await fetch(req);
        if (!res.ok) {
            console.log("Error al login");
            return;
        }
        result = await res.json();
    } catch (error) {
        console.log(error);
    }

      
}




// Roles
//     1 ->  Gerente General
//     2 ->  Gerente abarrotes
//     3 ->  Gerente cuidado personal
//     4 ->  Gerente mercancï¿½as
//     5 ->  Gerente frescos
//     7 ->  Cajero    
//     10 -> admin de sistemas
    