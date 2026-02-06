/**
 * Family Finance Quest - Enhanced Game Engine
 * With player movement, SPACE zone entry, and wants vs needs system
 */

// ============================================
// GAME STATE & CONFIGURATION
// ============================================

const GameConfig = {
    totalDays: 3,
    maxHearts: 3,
    startingCoins: 0,
    playerSpeed: 15, // pixels per keypress

    // Candy types for Match-3
    candyTypes: ['❤️', '💎', '🍏', '⭐', '💜'],
    candyColors: ['#ff6b6b', '#4ecdc4', '#95e1a3', '#ffd93d', '#a55eea'],

    // Work tasks
    workTasks: [
        { id: 'farm', name: 'Farm Work', icon: '🌾', reward: 15, staminaCost: 1, duration: 3000 },
        { id: 'mine', name: 'Mining', icon: '⛏️', reward: 25, staminaCost: 1, duration: 4000 },
        { id: 'deliver', name: 'Delivery', icon: '📦', reward: 10, staminaCost: 1, duration: 2000 },
        { id: 'clean', name: 'Cleaning', icon: '🧹', reward: 12, staminaCost: 1, duration: 2500 },
    ],

    // Shop items - NEEDS (food and Mom's items)
    needItems: [
        { id: 'bread', name: 'Bread', icon: '🍞', price: 10, type: 'food', effect: 1, desc: '+1 ❤️', category: 'need' },
        { id: 'fruit', name: 'Fruit', icon: '🍎', price: 15, type: 'food', effect: 1, desc: '+1 ❤️', category: 'need' },
        { id: 'veggie', name: 'Vegetables', icon: '🥕', price: 20, type: 'food', effect: 2, desc: '+2 ❤️', category: 'need' },
        { id: 'rice', name: 'Rice Bag', icon: '🍚', price: 12, type: 'task', desc: 'Mom needs this', category: 'need' },
        { id: 'milk', name: 'Milk', icon: '🥛', price: 8, type: 'task', desc: 'Mom needs this', category: 'need' },
        { id: 'eggs', name: 'Eggs', icon: '🥚', price: 10, type: 'task', desc: 'Mom needs this', category: 'need' },
    ],

    // Shop items - WANTS (tempting but useless!)
    wantItems: [
        { id: 'toy', name: 'Cool Toy', icon: '🤖', price: 25, type: 'want', desc: 'So shiny!', category: 'want' },
        { id: 'candy', name: 'Candy Bar', icon: '🍫', price: 15, type: 'want', desc: 'Yummy!', category: 'want' },
        { id: 'game', name: 'Video Game', icon: '🎮', price: 30, type: 'want', desc: 'Want it!', category: 'want' },
        { id: 'balloon', name: 'Balloon', icon: '🎈', price: 8, type: 'want', desc: 'Pretty!', category: 'want' },
        { id: 'icecream', name: 'Ice Cream', icon: '🍦', price: 12, type: 'want', desc: 'Delicious!', category: 'want' },
    ],

    // Daily tasks from Mom
    dailyTasks: {
        1: ['rice', 'milk'],
        2: ['bread', 'eggs', 'veggie'],
        3: ['milk', 'rice', 'fruit'],
    },

    // Zone bounds (percentages of map size)
    zones: {
        candy: { x: 0, y: 0, width: 50, height: 50, label: '🍬 Play' },
        home: { x: 50, y: 0, width: 50, height: 50, label: '🏠 Home' },
        market: { x: 0, y: 50, width: 50, height: 50, label: '🛒 Market' },
        work: { x: 50, y: 50, width: 50, height: 50, label: '💼 Work' },
    },

    // Mom dialogues
    momDialogues: {
        welcome: [
            "Welcome home, dear! Here's what we need today.",
            "Good morning! I have a shopping list for you.",
            "Hello sweetie! Can you help me with some errands?",
        ],
        taskComplete: [
            "Thank you so much! You're such a good helper!",
            "Perfect! You got everything we needed!",
            "Wonderful job! I'm so proud of you!",
        ],
        taskIncomplete: [
            "We're still missing some items, dear.",
            "Can you get the rest of the things we need?",
            "Almost there! Just a few more items.",
        ],
        noItems: [
            "You haven't gotten anything yet. Go earn some coins!",
            "The list is still empty. Try playing some games!",
        ],
        boughtWants: [
            "Oh dear, you spent money on things we don't need...",
            "Those items look fun, but we needed other things!",
        ],
    }
};

// Game State
const GameState = {
    currentScreen: 'loading',
    day: 1,
    hearts: GameConfig.maxHearts,
    coins: GameConfig.startingCoins,
    inventory: [],
    wantsInventory: [], // Track wasted money on wants
    completedTasks: [],
    totalCoinsEarned: 0,
    totalTasksCompleted: 0,
    totalWantsWasted: 0,
    isWorking: false,
    currentWorkTask: null,

    // Player position (percentage of map)
    player: {
        x: 50, // center
        y: 50,
    },
    currentZone: null,
};

// ============================================
// DOM ELEMENTS
// ============================================

const screens = {
    loading: document.getElementById('loading-screen'),
    menu: document.getElementById('menu-screen'),
    tutorial: document.getElementById('tutorial-screen'),
    world: document.getElementById('world-screen'),
    candy: document.getElementById('candy-screen'),
    work: document.getElementById('work-screen'),
    market: document.getElementById('market-screen'),
    home: document.getElementById('home-screen'),
    gameover: document.getElementById('gameover-screen'),
    victory: document.getElementById('victory-screen'),
};

const elements = {
    hearts: document.getElementById('hearts'),
    coins: document.getElementById('coins'),
    dayDisplay: document.getElementById('day-display'),
    candyBoard: document.getElementById('candy-board'),
    candyCoins: document.getElementById('candy-coins'),
    workTasks: document.getElementById('work-tasks'),
    workStamina: document.getElementById('work-stamina'),
    shopItems: document.getElementById('shop-items'),
    marketCoins: document.getElementById('market-coins'),
    inventory: document.getElementById('inventory'),
    momText: document.getElementById('mom-text'),
    momTasks: document.getElementById('mom-tasks'),
    giveInventory: document.getElementById('give-inventory'),
    endDayBtn: document.getElementById('end-day-btn'),
    tasksList: document.getElementById('tasks-list'),
    tasksModal: document.getElementById('tasks-modal'),
    player: document.getElementById('player'),
    zonePrompt: document.getElementById('zone-prompt'),
    controlsHint: document.getElementById('controls-hint'),
};

// ============================================
// SCREEN MANAGEMENT
// ============================================

function showScreen(screenName) {
    Object.values(screens).forEach(screen => {
        screen.classList.remove('active');
    });

    if (screens[screenName]) {
        screens[screenName].classList.add('active');
        GameState.currentScreen = screenName;

        // Show/hide controls hint
        if (elements.controlsHint) {
            elements.controlsHint.style.display = screenName === 'world' ? 'block' : 'none';
        }

        // Initialize screen-specific content
        switch (screenName) {
            case 'world':
                updateHUD();
                updatePlayerPosition();
                break;
            case 'candy':
                initCandyBoard();
                break;
            case 'work':
                initWorkZone();
                break;
            case 'market':
                initMarket();
                break;
            case 'home':
                initHome();
                break;
        }
    }
}

function updateHUD() {
    // Update hearts display
    let heartsStr = '';
    for (let i = 0; i < GameConfig.maxHearts; i++) {
        heartsStr += i < GameState.hearts ? '❤️' : '🖤';
    }
    elements.hearts.textContent = heartsStr;

    // Update coins
    elements.coins.textContent = GameState.coins;
    if (elements.candyCoins) elements.candyCoins.textContent = GameState.coins;
    if (elements.marketCoins) elements.marketCoins.textContent = GameState.coins;

    // Update day
    elements.dayDisplay.textContent = `Day ${GameState.day}`;

    // Update work stamina
    if (elements.workStamina) elements.workStamina.textContent = GameState.hearts;
}

// ============================================
// PLAYER MOVEMENT
// ============================================

function updatePlayerPosition() {
    if (!elements.player) return;
    elements.player.style.left = `${GameState.player.x}%`;
    elements.player.style.top = `${GameState.player.y}%`;

    checkPlayerZone();
}

function movePlayer(dx, dy) {
    if (GameState.currentScreen !== 'world') return;

    // Update position with bounds checking
    GameState.player.x = Math.max(5, Math.min(95, GameState.player.x + dx));
    GameState.player.y = Math.max(12, Math.min(92, GameState.player.y + dy)); // Account for HUD

    updatePlayerPosition();
}

function checkPlayerZone() {
    const px = GameState.player.x;
    const py = GameState.player.y;

    // Remove all zone highlight
    document.querySelectorAll('.zone-overlay').forEach(z => z.classList.remove('player-nearby'));

    // Check which zone the player is in
    let currentZone = null;
    for (const [zoneName, zone] of Object.entries(GameConfig.zones)) {
        if (px >= zone.x && px <= zone.x + zone.width &&
            py >= zone.y && py <= zone.y + zone.height) {
            currentZone = zoneName;
            const zoneEl = document.getElementById(`${zoneName}-zone`);
            if (zoneEl) zoneEl.classList.add('player-nearby');
            break;
        }
    }

    GameState.currentZone = currentZone;

    // Show/hide zone prompt
    if (elements.zonePrompt) {
        if (currentZone) {
            elements.zonePrompt.classList.remove('hidden');
            elements.zonePrompt.querySelector('span').innerHTML =
                `Press <kbd>SPACE</kbd> to enter ${GameConfig.zones[currentZone].label}`;
        } else {
            elements.zonePrompt.classList.add('hidden');
        }
    }
}

function enterCurrentZone() {
    if (GameState.currentZone && GameState.currentScreen === 'world') {
        showScreen(GameState.currentZone);
    }
}

// Keyboard input
document.addEventListener('keydown', (e) => {
    if (GameState.currentScreen !== 'world') return;

    const speed = GameConfig.playerSpeed / 3; // Convert to percentage

    switch (e.key) {
        case 'ArrowUp':
        case 'w':
        case 'W':
            movePlayer(0, -speed);
            e.preventDefault();
            break;
        case 'ArrowDown':
        case 's':
        case 'S':
            movePlayer(0, speed);
            e.preventDefault();
            break;
        case 'ArrowLeft':
        case 'a':
        case 'A':
            movePlayer(-speed, 0);
            e.preventDefault();
            break;
        case 'ArrowRight':
        case 'd':
        case 'D':
            movePlayer(speed, 0);
            e.preventDefault();
            break;
        case ' ':
            enterCurrentZone();
            e.preventDefault();
            break;
    }
});

// ============================================
// CANDY CRUSH GAME
// ============================================

let candyBoard = [];
let selectedCandy = null;
let isProcessing = false;

function initCandyBoard() {
    elements.candyBoard.innerHTML = '';
    candyBoard = [];
    selectedCandy = null;

    // Create 8x8 board
    for (let row = 0; row < 8; row++) {
        candyBoard[row] = [];
        for (let col = 0; col < 8; col++) {
            const candy = createCandy(row, col);
            candyBoard[row][col] = candy;
            elements.candyBoard.appendChild(candy.element);
        }
    }

    // Initial match check
    setTimeout(() => checkAndRemoveMatches(), 500);
}

function createCandy(row, col, animate = true) {
    const typeIndex = Math.floor(Math.random() * GameConfig.candyTypes.length);
    const element = document.createElement('div');
    element.className = 'candy' + (animate ? ' fade-in' : '');
    element.textContent = GameConfig.candyTypes[typeIndex];
    element.style.background = `linear-gradient(135deg, ${GameConfig.candyColors[typeIndex]}40, ${GameConfig.candyColors[typeIndex]}20)`;
    element.dataset.row = row;
    element.dataset.col = col;
    element.dataset.type = typeIndex;

    element.addEventListener('click', () => handleCandyClick(row, col));

    return {
        element,
        type: typeIndex,
        row,
        col
    };
}

function handleCandyClick(row, col) {
    if (isProcessing) return;

    const candy = candyBoard[row][col];

    if (!selectedCandy) {
        selectedCandy = { row, col };
        candy.element.classList.add('selected');
    } else if (selectedCandy.row === row && selectedCandy.col === col) {
        candy.element.classList.remove('selected');
        selectedCandy = null;
    } else if (isAdjacent(selectedCandy.row, selectedCandy.col, row, col)) {
        const prevCandy = candyBoard[selectedCandy.row][selectedCandy.col];
        prevCandy.element.classList.remove('selected');

        swapCandies(selectedCandy.row, selectedCandy.col, row, col);
        selectedCandy = null;
    } else {
        candyBoard[selectedCandy.row][selectedCandy.col].element.classList.remove('selected');
        selectedCandy = { row, col };
        candy.element.classList.add('selected');
    }
}

function isAdjacent(r1, c1, r2, c2) {
    return (Math.abs(r1 - r2) === 1 && c1 === c2) ||
        (Math.abs(c1 - c2) === 1 && r1 === r2);
}

function swapCandies(r1, c1, r2, c2) {
    isProcessing = true;

    const temp = candyBoard[r1][c1];
    candyBoard[r1][c1] = candyBoard[r2][c2];
    candyBoard[r2][c2] = temp;

    candyBoard[r1][c1].row = r1;
    candyBoard[r1][c1].col = c1;
    candyBoard[r2][c2].row = r2;
    candyBoard[r2][c2].col = c2;

    setTimeout(() => {
        const matches = findMatches();
        if (matches.length > 0) {
            removeMatches(matches);
        } else {
            const temp = candyBoard[r1][c1];
            candyBoard[r1][c1] = candyBoard[r2][c2];
            candyBoard[r2][c2] = temp;

            candyBoard[r1][c1].row = r1;
            candyBoard[r1][c1].col = c1;
            candyBoard[r2][c2].row = r2;
            candyBoard[r2][c2].col = c2;

            isProcessing = false;
        }
        refreshBoard();
    }, 100);
}

function findMatches() {
    const matches = new Set();

    for (let row = 0; row < 8; row++) {
        for (let col = 0; col < 6; col++) {
            const type = candyBoard[row][col].type;
            if (candyBoard[row][col + 1].type === type &&
                candyBoard[row][col + 2].type === type) {
                matches.add(`${row},${col}`);
                matches.add(`${row},${col + 1}`);
                matches.add(`${row},${col + 2}`);
            }
        }
    }

    for (let col = 0; col < 8; col++) {
        for (let row = 0; row < 6; row++) {
            const type = candyBoard[row][col].type;
            if (candyBoard[row + 1][col].type === type &&
                candyBoard[row + 2][col].type === type) {
                matches.add(`${row},${col}`);
                matches.add(`${row + 1},${col}`);
                matches.add(`${row + 2},${col}`);
            }
        }
    }

    return Array.from(matches).map(coord => {
        const [row, col] = coord.split(',').map(Number);
        return { row, col };
    });
}

function removeMatches(matches) {
    const coinsEarned = matches.length * 2;
    GameState.coins += coinsEarned;
    GameState.totalCoinsEarned += coinsEarned;
    updateHUD();

    showFloatingText(`+${coinsEarned} 🪙`, elements.candyBoard);

    matches.forEach(({ row, col }) => {
        candyBoard[row][col].element.classList.add('matched');
    });

    setTimeout(() => {
        dropCandies(matches);
    }, 300);
}

function dropCandies(matches) {
    const columns = {};
    matches.forEach(({ row, col }) => {
        if (!columns[col]) columns[col] = [];
        columns[col].push(row);
    });

    Object.keys(columns).forEach(col => {
        const colNum = parseInt(col);
        const removedRows = columns[col].sort((a, b) => b - a);

        removedRows.forEach(removedRow => {
            for (let row = removedRow; row > 0; row--) {
                candyBoard[row][colNum] = candyBoard[row - 1][colNum];
                candyBoard[row][colNum].row = row;
            }
            candyBoard[0][colNum] = createCandy(0, colNum, true);
        });
    });

    refreshBoard();

    setTimeout(() => {
        checkAndRemoveMatches();
    }, 300);
}

function checkAndRemoveMatches() {
    const matches = findMatches();
    if (matches.length > 0) {
        removeMatches(matches);
    } else {
        isProcessing = false;
    }
}

function refreshBoard() {
    elements.candyBoard.innerHTML = '';
    for (let row = 0; row < 8; row++) {
        for (let col = 0; col < 8; col++) {
            const candy = candyBoard[row][col];
            candy.element.dataset.row = row;
            candy.element.dataset.col = col;
            candy.element.onclick = () => handleCandyClick(row, col);
            elements.candyBoard.appendChild(candy.element);
        }
    }
}

// ============================================
// WORK ZONE
// ============================================

function initWorkZone() {
    elements.workTasks.innerHTML = '';
    elements.workStamina.textContent = GameState.hearts;

    // Check if player has stamina to work
    if (GameState.hearts <= 0) {
        elements.workTasks.innerHTML = `
            <div class="no-stamina-warning">
                <h3>😫 Too Tired!</h3>
                <p>You have no stamina to work!</p>
                <p>Go to the Market and buy food to recover.</p>
            </div>
        `;
        return;
    }

    GameConfig.workTasks.forEach(task => {
        const taskEl = document.createElement('div');
        taskEl.className = 'work-task' + (GameState.hearts < task.staminaCost ? ' disabled' : '');
        taskEl.innerHTML = `
            <div class="task-icon">${task.icon}</div>
            <div class="task-name">${task.name}</div>
            <div class="task-reward">+${task.reward} 🪙</div>
            <div class="task-cost">-${task.staminaCost} ❤️</div>
            <div class="progress-bar"><div class="progress-fill"></div></div>
        `;

        taskEl.addEventListener('click', () => startWork(task, taskEl));
        elements.workTasks.appendChild(taskEl);
    });
}

function startWork(task, element) {
    if (GameState.isWorking || GameState.hearts < task.staminaCost) {
        if (GameState.hearts < task.staminaCost) {
            showFloatingText('Need more ❤️!', element);
            element.classList.add('shake');
            setTimeout(() => element.classList.remove('shake'), 500);
        }
        return;
    }

    GameState.isWorking = true;
    GameState.currentWorkTask = task;
    element.classList.add('working');

    const progressFill = element.querySelector('.progress-fill');
    let progress = 0;
    const interval = setInterval(() => {
        progress += 100 / (task.duration / 100);
        progressFill.style.width = `${Math.min(progress, 100)}%`;

        if (progress >= 100) {
            clearInterval(interval);
            completeWork(task, element);
        }
    }, 100);
}

function completeWork(task, element) {
    GameState.hearts -= task.staminaCost;
    GameState.coins += task.reward;
    GameState.totalCoinsEarned += task.reward;

    GameState.isWorking = false;
    GameState.currentWorkTask = null;
    element.classList.remove('working');

    showFloatingText(`+${task.reward} 🪙`, element);

    updateHUD();
    elements.workStamina.textContent = GameState.hearts;

    // Refresh work zone to update stamina display
    initWorkZone();
}

function getMinFoodPrice() {
    return Math.min(...GameConfig.needItems
        .filter(item => item.type === 'food')
        .map(item => item.price));
}

// ============================================
// MARKET / SHOP with WANTS vs NEEDS
// ============================================

function initMarket() {
    elements.shopItems.innerHTML = '';
    elements.marketCoins.textContent = GameState.coins;

    // Get today's tasks to highlight needed items
    const todayTasks = GameConfig.dailyTasks[GameState.day] || [];

    // Combine needs and wants, but shuffle to make wants tempting
    const allItems = [...GameConfig.needItems, ...GameConfig.wantItems];

    // Shuffle to randomize positions
    const shuffledItems = allItems.sort(() => Math.random() - 0.5);

    shuffledItems.forEach(item => {
        const itemEl = document.createElement('div');
        const canAfford = GameState.coins >= item.price;
        const isNeeded = todayTasks.includes(item.id);

        // Determine item class
        let itemClass = 'shop-item';
        if (item.category === 'want') {
            itemClass += ' want';
        } else if (isNeeded || item.type === 'food') {
            itemClass += ' need';
        }
        if (!canAfford) itemClass += ' disabled';

        itemEl.className = itemClass;
        itemEl.innerHTML = `
            <div class="item-icon">${item.icon}</div>
            <div class="item-name">${item.name}</div>
            <div class="item-price">${item.price} 🪙</div>
            <div class="item-effect">${item.desc}</div>
        `;

        itemEl.addEventListener('click', () => buyItem(item, itemEl));
        elements.shopItems.appendChild(itemEl);
    });

    updateInventoryDisplay();
}

function buyItem(item, element) {
    if (GameState.coins < item.price) {
        showFloatingText('Not enough 🪙!', element);
        element.classList.add('shake');
        setTimeout(() => element.classList.remove('shake'), 500);
        return;
    }

    // Deduct coins
    GameState.coins -= item.price;

    if (item.type === 'food') {
        // Restore hearts immediately
        GameState.hearts = Math.min(GameState.hearts + item.effect, GameConfig.maxHearts);
        showFloatingText(`+${item.effect} ❤️`, element);
    } else if (item.type === 'want') {
        // Bought a want! Track it but it's useless
        GameState.wantsInventory.push(item.id);
        GameState.totalWantsWasted += item.price;
        showFloatingText(`Bought ${item.icon}! (But you don't need it!)`, element);
    } else {
        // Add to inventory (task items for Mom)
        GameState.inventory.push(item.id);
        showFloatingText(`Got ${item.icon}!`, element);
    }

    updateHUD();
    initMarket();
}

function updateInventoryDisplay() {
    elements.inventory.innerHTML = '';

    if (GameState.inventory.length === 0 && GameState.wantsInventory.length === 0) {
        elements.inventory.innerHTML = '<span style="color: #888;">Empty</span>';
        return;
    }

    // Show needed items
    const counts = {};
    GameState.inventory.forEach(id => {
        counts[id] = (counts[id] || 0) + 1;
    });

    Object.keys(counts).forEach(id => {
        const item = GameConfig.needItems.find(i => i.id === id);
        if (item) {
            const el = document.createElement('div');
            el.className = 'inventory-item';
            el.innerHTML = `${item.icon} x${counts[id]}`;
            elements.inventory.appendChild(el);
        }
    });

    // Show wasted wants with different styling
    const wantCounts = {};
    GameState.wantsInventory.forEach(id => {
        wantCounts[id] = (wantCounts[id] || 0) + 1;
    });

    Object.keys(wantCounts).forEach(id => {
        const item = GameConfig.wantItems.find(i => i.id === id);
        if (item) {
            const el = document.createElement('div');
            el.className = 'inventory-item';
            el.style.opacity = '0.6';
            el.innerHTML = `${item.icon} x${wantCounts[id]} <small>(want)</small>`;
            elements.inventory.appendChild(el);
        }
    });
}

// ============================================
// HOME / MOM
// ============================================

function initHome() {
    const todayTasks = GameConfig.dailyTasks[GameState.day] || [];

    // Mom dialogue based on situation
    const completedCount = todayTasks.filter(id =>
        GameState.inventory.includes(id) || GameState.completedTasks.includes(id)
    ).length;

    let dialogues;
    if (GameState.wantsInventory.length > 0 && completedCount < todayTasks.length) {
        dialogues = GameConfig.momDialogues.boughtWants;
    } else if (GameState.inventory.length === 0 && completedCount === 0) {
        dialogues = GameConfig.momDialogues.noItems;
    } else if (completedCount === todayTasks.length) {
        dialogues = GameConfig.momDialogues.taskComplete;
    } else if (completedCount > 0) {
        dialogues = GameConfig.momDialogues.taskIncomplete;
    } else {
        dialogues = GameConfig.momDialogues.welcome;
    }

    elements.momText.textContent = dialogues[Math.floor(Math.random() * dialogues.length)];

    // Task list
    elements.momTasks.innerHTML = '';
    todayTasks.forEach(taskId => {
        const item = GameConfig.needItems.find(i => i.id === taskId);
        const completed = GameState.completedTasks.includes(taskId);
        const li = document.createElement('li');
        li.className = completed ? 'completed' : '';
        li.innerHTML = `
            <span>${completed ? '✅' : '⬜'}</span>
            <span>${item ? item.icon : '📦'} ${item ? item.name : taskId}</span>
        `;
        elements.momTasks.appendChild(li);
    });

    // Give items section
    elements.giveInventory.innerHTML = '';

    const relevantItems = GameState.inventory.filter(id => todayTasks.includes(id));

    if (relevantItems.length === 0) {
        elements.giveInventory.innerHTML = '<span style="color: #888;">No task items in inventory</span>';
    } else {
        relevantItems.forEach((id, index) => {
            const item = GameConfig.needItems.find(i => i.id === id);
            if (item) {
                const el = document.createElement('div');
                el.className = 'inventory-item';
                el.innerHTML = `${item.icon} ${item.name}`;
                el.addEventListener('click', () => giveItemToMom(id, index));
                elements.giveInventory.appendChild(el);
            }
        });
    }

    // End day button
    const allCompleted = todayTasks.every(id =>
        GameState.completedTasks.includes(id)
    );
    elements.endDayBtn.disabled = !allCompleted;
}

function giveItemToMom(itemId, inventoryIndex) {
    const idx = GameState.inventory.indexOf(itemId);
    if (idx > -1) {
        GameState.inventory.splice(idx, 1);
    }

    if (!GameState.completedTasks.includes(itemId)) {
        GameState.completedTasks.push(itemId);
        GameState.totalTasksCompleted++;
    }

    showFloatingText('Mom: Thank you! 💕', elements.giveInventory);

    initHome();
}

function endDay() {
    const todayTasks = GameConfig.dailyTasks[GameState.day] || [];
    const allCompleted = todayTasks.every(id =>
        GameState.completedTasks.includes(id)
    );

    if (!allCompleted) return;

    // Penalty: if player has no stamina and didn't eat, lose a heart
    if (GameState.hearts <= 0) {
        gameOver("You ran out of stamina and couldn't afford food!");
        return;
    }

    // Clear completed tasks for next day
    GameState.completedTasks = [];
    GameState.wantsInventory = []; // Clear wasted wants

    if (GameState.day >= GameConfig.totalDays) {
        victory();
    } else {
        GameState.day++;
        // Reset player position to center
        GameState.player.x = 50;
        GameState.player.y = 50;
        showScreen('world');
        showFloatingText(`Day ${GameState.day} started!`, document.getElementById('hud'));
    }
}

// ============================================
// GAME OVER & VICTORY
// ============================================

function gameOver(reason) {
    document.getElementById('gameover-reason').textContent = reason;
    document.getElementById('final-days').textContent = GameState.day;
    document.getElementById('final-coins').textContent = GameState.totalCoinsEarned;
    showScreen('gameover');
}

function victory() {
    document.getElementById('victory-coins').textContent = GameState.totalCoinsEarned;
    document.getElementById('victory-tasks').textContent = GameState.totalTasksCompleted;
    showScreen('victory');
}

function resetGame() {
    GameState.day = 1;
    GameState.hearts = GameConfig.maxHearts;
    GameState.coins = GameConfig.startingCoins;
    GameState.inventory = [];
    GameState.wantsInventory = [];
    GameState.completedTasks = [];
    GameState.totalCoinsEarned = 0;
    GameState.totalTasksCompleted = 0;
    GameState.totalWantsWasted = 0;
    GameState.isWorking = false;
    GameState.currentWorkTask = null;
    GameState.player.x = 50;
    GameState.player.y = 50;
    GameState.currentZone = null;
}

// ============================================
// UI HELPERS
// ============================================

function showFloatingText(text, parentElement) {
    const el = document.createElement('div');
    el.className = 'floating-coin';
    el.textContent = text;
    el.style.left = '50%';
    el.style.top = '50%';
    el.style.transform = 'translate(-50%, -50%)';

    if (parentElement) {
        parentElement.style.position = 'relative';
        parentElement.appendChild(el);
    } else {
        document.body.appendChild(el);
    }

    setTimeout(() => el.remove(), 1000);
}

function showTasksModal() {
    const todayTasks = GameConfig.dailyTasks[GameState.day] || [];
    elements.tasksList.innerHTML = '';

    todayTasks.forEach(taskId => {
        const item = GameConfig.needItems.find(i => i.id === taskId);
        const completed = GameState.completedTasks.includes(taskId);
        const li = document.createElement('li');
        li.innerHTML = `
            <span>${completed ? '✅' : '⬜'}</span>
            <span>${item ? item.icon : '📦'} ${item ? item.name : taskId}</span>
        `;
        elements.tasksList.appendChild(li);
    });

    elements.tasksModal.classList.add('active');
}

function hideTasksModal() {
    elements.tasksModal.classList.remove('active');
}

// ============================================
// EVENT LISTENERS
// ============================================

document.addEventListener('DOMContentLoaded', () => {
    // Loading screen
    setTimeout(() => {
        showScreen('menu');
    }, 2500);

    // Menu buttons
    document.getElementById('play-btn').addEventListener('click', () => {
        resetGame();
        showScreen('world');
    });

    document.getElementById('how-to-play-btn').addEventListener('click', () => {
        showScreen('tutorial');
    });

    document.getElementById('back-to-menu-btn').addEventListener('click', () => {
        showScreen('menu');
    });

    // Zone clicks (backup for mouse users)
    document.querySelectorAll('.zone-overlay').forEach(zone => {
        zone.addEventListener('click', () => {
            const zoneName = zone.dataset.zone;
            showScreen(zoneName);
        });
    });

    // Back buttons
    document.querySelectorAll('.back-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            showScreen('world');
        });
    });

    // Candy finish button
    document.getElementById('finish-candy-btn').addEventListener('click', () => {
        showScreen('world');
    });

    // Tasks modal
    document.getElementById('tasks-btn').addEventListener('click', showTasksModal);
    document.querySelector('.close-modal-btn').addEventListener('click', hideTasksModal);

    // End day
    elements.endDayBtn.addEventListener('click', endDay);

    // Restart buttons
    document.getElementById('restart-btn').addEventListener('click', () => {
        resetGame();
        showScreen('world');
    });

    document.getElementById('play-again-btn').addEventListener('click', () => {
        resetGame();
        showScreen('world');
    });
});
