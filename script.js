window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'update_hud') {
        updateBar('health', data.health);
        updateBar('armor', data.armor);
        updateBar('food', data.food);
        updateBar('water', data.water);
        updateBar('fuel', data.fuel);
        
        document.getElementById('speed-value').innerText = data.speed;

        const seatbeltElement = document.getElementById('seatbelt');
        if (data.seatbelt) {
            seatbeltElement.classList.add('green');
            seatbeltElement.classList.remove('red');
        } else {
            seatbeltElement.classList.add('red');
            seatbeltElement.classList.remove('green');
        }

        const topHud = document.getElementById('top-hud');
        if (data.speed > 0 || data.fuel > 0 || data.seatbelt) {
            topHud.style.display = 'flex';
        } else {
            topHud.style.display = 'none';
        }
    } else if (data.action === 'toggle_hud') {
        document.getElementById('hud').style.display = data.enabled ? 'flex' : 'none';
    }
});


function updateBar(id, value) {
    const bar = document.getElementById(`${id}-fill`);
    const percentage = value / 100;
    if (percentage === 0) {
        bar.classList.add('zero');
    } else {
        bar.classList.remove('zero');
    }
    bar.style.height = `${percentage * 100}%`;
}
