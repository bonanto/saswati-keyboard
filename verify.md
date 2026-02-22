## 🔐 Verifying Package Authenticity

To ensure that the packages you download have not been tampered with and genuinely originate from the developer, I have signed the packages. You can verify the package signatures before installation.

### 1. Download the Public Key

#### First, download the public GPG key used to sign the Saswati packages:
##### Download the public key via wget
```bash
wget -O saswati-public.key [https://raw.githubusercontent.com/skb92/saswati/main/saswati-public.key](https://raw.githubusercontent.com/skb92/saswati/main/saswati-public.key)
```
*(Note: If you downloaded the key manually via the browser, ensure it is saved as `saswati-public.key` in your current terminal directory.)*

---

### 2. Verification on Fedora, RHEL, CentOS, and SUSE (.rpm)

RPM has built-in support for verifying signed packages.

**Step A: Import the Public Key** 

Import the public key into your system's RPM database. You only need to do this once.  

```bash
sudo rpm --import saswati-public.key
```

**Step B: Verify the Package**  

Run the **`rpm --checksig`** command against the downloaded `.rpm` package:  

```bash
rpm --checksig saswati-keyboard-1.0.0-1.fc43.noarch.rpm
```
**Expected Output:** You should see **`digests signatures OK`**  or  **`rsa sha1 (md5) pgp md5 OK`**, confirming the package is valid.

---

### 3. Verification on Debian, Ubuntu, and Linux Mint (.deb)

For Debian-based systems, you can verify the package using: `dpkg-sig`. 

**Step A: Install Dependencies and Import the Key**  

If you don't have `dpkg-sig` installed, install it first, then import the key into your user's GPG keyring:  

```bash
sudo apt update
sudo apt install dpkg-sig
gpg --import saswati-public.key
```

**Step B: Verify the Package**  

Run the verification command against the `.deb` file:  

```bash
dpkg-sig --verify saswati-keyboard_1.0.0_all.deb
```
**Expected Output:** You should see a status of **`GOODSIG`** followed by the key ID, confirming the signature is valid. You should see something like: "Good signature from "shyamal (Saswati Keyboard Package Signer) <bonanto18@protonmail.com>""

---

### 4. Generic Verification (Detached Signatures)

If you are downloading a source tarball (`.tar.gz`) or prefer using detached signature files (`.sig` or `.asc`) provided in the GitHub Releases, you can use standard GPG commands on any Linux distribution (Arch, Alpine, Void, etc.). Keep the Key file, the packages and the asc files in the same folder. Then open the folder in Terminal and follow the instructions:

#### Step A: Import the Key**  

```bash
gpg --import saswati-public.key
```
#### Step B: Verify the Files**  
**To verify the Source Tarball (.tar.gz):**  

Ensure both the downloaded archive and the signature file are in the same directory, then run:  

```bash
gpg --verify saswati-keyboard-1.0.0.tar.gz.asc saswati-keyboard-1.0.0.tar.gz
```  

**To verify the Debian package (.deb):**  

```bash
gpg --verify saswati-keyboard_1.0.0_all.deb.asc saswati-keyboard_1.0.0_all.deb
```
**Expected Output:** Look for the line **`Good signature from "shyamal (Saswati Keyboard Package Signer) <bonanto18@protonmail.com>" [ultimate]`**. 

> **⚠️ Note:** GPG might show a warning saying `This key is not certified with a trusted signature!`. This is normal and simply means I haven't explicitly marked the or paid some corporation to verify "Trust". As long as it says **Good signature**, the file's integrity is intact. Feel free to contact me.
