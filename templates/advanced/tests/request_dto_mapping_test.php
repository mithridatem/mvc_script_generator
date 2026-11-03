<?php

declare(strict_types=1);

// Lancer : php tests/request_dto_mapping_test.php
require dirname(__DIR__) . '/vendor/autoload.php';

use App\DTO\LoginInput;
use App\DTO\RegisterUserInput;
use Mithridatem\Routing\Http\ParameterCollectionRequestInterface;
use Mithridatem\Routing\Http\Request;
use Mithridatem\Routing\Route;
use Mithridatem\Routing\Router;

function assertMapping(bool $condition, string $message): void
{
    if (!$condition) {
        throw new RuntimeException($message);
    }
}

$router = new Router();
$router->map(Route::post('/register', static fn (ParameterCollectionRequestInterface $request)
    => RegisterUserInput::fromArray($request->allPost())));
$router->map(Route::post('/login', static fn (ParameterCollectionRequestInterface $request)
    => LoginInput::fromArray($request->allPost())));

$register = $router->dispatch(new Request('/register', 'POST', post: [
    'firstname' => ' Ada ',
    'lastname' => ' Lovelace ',
    'email' => ' ada@example.test ',
    'password' => ' secret ',
    'confirm_password' => ' secret ',
    'csrf_token' => 'form-token',
    'unexpected' => 'ignored',
]));
assertMapping($register instanceof RegisterUserInput, 'Register : mauvais DTO');
assertMapping($register->firstname === 'Ada', 'Register : prénom non normalisé');
assertMapping($register->lastname === 'Lovelace', 'Register : nom non normalisé');
assertMapping($register->email === 'ada@example.test', 'Register : email non normalisé');
assertMapping($register->password === ' secret ', 'Register : mot de passe modifié');
assertMapping($register->confirmPassword === ' secret ', 'Register : confirmation modifiée');

$login = $router->dispatch(new Request('/login', 'POST', post: [
    'email' => ' ada@example.test ',
    'password' => ' secret ',
    'csrf_token' => 'form-token',
]));
assertMapping($login instanceof LoginInput, 'Login : mauvais DTO');
assertMapping($login->email === 'ada@example.test', 'Login : email non normalisé');
assertMapping($login->password === ' secret ', 'Login : mot de passe modifié');

$invalid = $router->dispatch(new Request('/login', 'POST', post: [
    'email' => ['bad'],
    'password' => ['bad'],
]));
assertMapping($invalid->email === null, 'Login : email tableau accepté');
assertMapping($invalid->password === null, 'Login : mot de passe tableau accepté');

echo "Request to DTO mapping : OK\n";
