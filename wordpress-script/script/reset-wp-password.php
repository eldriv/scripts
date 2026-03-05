#!/usr/bin/env php
<?php
/**
 * List WordPress users or reset a user's password (no WP-CLI required).
 * Run inside the WordPress container: php /var/www/html/reset-wp-password.php [user_login new_password]
 */
if (php_sapi_name() !== 'cli') {
    exit(1);
}

define('WP_USE_THEMES', false);
$wp_load = __DIR__ . '/wp-load.php';
if (!is_file($wp_load)) {
    fwrite(STDERR, "Error: wp-load.php not found. Run from WordPress root.\n");
    exit(1);
}
require_once $wp_load;

if ($argc < 2) {
    // List users
    $users = get_users(['orderby' => 'login']);
    foreach ($users as $u) {
        printf("%-20s ID %d  %s\n", $u->user_login, $u->ID, $u->user_email);
    }
    exit(0);
}

if ($argc < 3) {
    fwrite(STDERR, "Usage: php reset-wp-password.php <user_login|user_id|email> <new_password>\n");
    fwrite(STDERR, "   Or: php reset-wp-password.php   (list users)\n");
    exit(1);
}

$login = $argv[1];
$password = $argv[2];
$user = null;
if (is_numeric($login)) {
    $user = get_user_by('id', (int) $login);
}
if (!$user) {
    $user = get_user_by('login', $login);
}
if (!$user) {
    $user = get_user_by('email', $login);
}
if (!$user) {
    fwrite(STDERR, "User not found: {$login}. Run with no args to list users (login / ID / email).\n");
    exit(1);
}

wp_set_password($password, $user->ID);
echo "Password updated for {$user->user_login}. Log in at /wp-admin\n";
exit(0);
