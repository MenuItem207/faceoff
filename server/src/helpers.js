module.exports = class Helpers {
    /**
 * Generates a code for a user to join a device
 * 
 * @param {int} length 
 * @returns 
 */
    static makeJoinCode(length) {
        var result = '';
        var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        var charactersLength = characters.length;
        for (var i = 0; i < length; i++) {
            result += characters.charAt(Math.floor(Math.random() * charactersLength));
        }
        return result;
    }

}